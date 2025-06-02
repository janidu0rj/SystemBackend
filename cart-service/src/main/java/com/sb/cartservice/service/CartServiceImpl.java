package com.sb.cartservice.service;

import com.sb.billservice.grpc.BillRequest;
import com.sb.billservice.grpc.BillResponse;
import com.sb.billservice.grpc.BillUpdateServiceGrpc;
import com.sb.cartservice.dto.CartDTO;
import com.sb.cartservice.model.Cart;
import com.sb.cartservice.repository.CartRepository;
import com.sb.customerservice.grpc.GetUsernameRequest;
import com.sb.customerservice.grpc.GetUsernameResponse;
import com.sb.customerservice.grpc.UserInfoServiceGrpc;
import com.sb.productservice.grpc.ProductDetailsRequest;
import com.sb.productservice.grpc.ProductDetailsResponse;
import com.sb.productservice.grpc.ProductDetailsServiceGrpc;
import jakarta.servlet.http.HttpServletRequest;
import net.devh.boot.grpc.client.inject.GrpcClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class CartServiceImpl implements CartService {

    private final CartRepository cartRepository;
    private final HttpServletRequest request;
    private final BarcodeListenerService barcodeListenerService;

    private static final Logger logger = LoggerFactory.getLogger(CartServiceImpl.class);

    public CartServiceImpl(CartRepository cartRepository, HttpServletRequest request, BarcodeListenerService barcodeListenerService) {
        this.cartRepository = cartRepository;
        this.request = request;
        this.barcodeListenerService = barcodeListenerService;
    }

    @GrpcClient("bill-update-service")
    private BillUpdateServiceGrpc.BillUpdateServiceBlockingStub billUpdateServiceBlockingStub;

    @GrpcClient("customer-service")
    private UserInfoServiceGrpc.UserInfoServiceBlockingStub userInfoStub;

    @GrpcClient("product-service")
    private ProductDetailsServiceGrpc.ProductDetailsServiceBlockingStub productDetailsServiceStub;

    /** Helper to extract username from JWT in Authorization header. */
    private String extractUsernameFromRequest() {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            logger.error("❌ Missing or invalid Authorization header");
            throw new SecurityException("Missing or invalid Authorization header");
        }
        String jwt = authHeader.substring(7);
        try {
            GetUsernameRequest grpcRequest = GetUsernameRequest.newBuilder().setJwt(jwt).build();
            GetUsernameResponse grpcResponse = userInfoStub.getUsername(grpcRequest);
            String username = grpcResponse.getUsername();
            if (username.isEmpty()) {
                logger.error("❌ Username extraction failed via gRPC for JWT: {}", jwt);
                throw new SecurityException("Unable to extract username from JWT");
            }
            return username;
        } catch (Exception e) {
            logger.error("❌ gRPC call failed while extracting username: {}", e.getMessage(), e);
            throw new SecurityException("Error extracting username from JWT via gRPC", e);
        }
    }

    private ProductDetailsResponse fetchProductDetails(String barcode) {
        ProductDetailsRequest req = ProductDetailsRequest.newBuilder()
                .setBarcode(barcode)
                .build();
        try {
            return productDetailsServiceStub.getProductDetails(req);
        } catch (Exception e) {
            logger.error("❌ gRPC call to product service failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch product details for barcode: " + barcode, e);
        }
    }


    @Override
    @Transactional(readOnly = true)
    public List<CartDTO> getAllItems() {

        String userId = extractUsernameFromRequest();
        logger.info("📦 Fetching all cart items for user: {}", userId);

        List<Cart> cartItems = cartRepository.findByUserId(userId);

        List<CartDTO> dtoList = cartItems.stream().map(cart -> {
            CartDTO dto = new CartDTO();
            dto.setId(cart.getId());
            dto.setName(cart.getName());
            dto.setQuantity(cart.getQuantity());
            dto.setPrice(cart.getPrice());
            return dto;
        }).toList();

        logger.info("✅ Found {} cart item(s) for user: {}", dtoList.size(), userId);
        return dtoList;
    }

    @Override
    @Transactional
    public CartDTO addItems(CartDTO item) {

        logger.info("🛒 Adding item to cart: {}", item.getName());

        String userId = extractUsernameFromRequest();

        // 1. Get the most recent barcode scanned
        String barcode = barcodeListenerService.getLatestBarcode();
        if (barcode == null || barcode.isEmpty()) {
            logger.warn("❌ No barcode scanned/found. Cannot add item.");
            throw new IllegalArgumentException("No barcode scanned. Please scan an item first.");
        }

        // 2. Fetch product details via gRPC (using barcode)
        ProductDetailsRequest req = ProductDetailsRequest.newBuilder()
                .setBarcode(barcode)
                .build();
        ProductDetailsResponse productResp;
        try {
            productResp = productDetailsServiceStub.getProductDetails(req);
        } catch (Exception e) {
            logger.error("❌ gRPC call to product service failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch product details for barcode: " + barcode, e);
        }

        if (!productResp.getExists()) {
            logger.warn("❌ Product not found for barcode: {}", barcode);
            throw new IllegalArgumentException("Product not found for barcode: " + barcode);
        }

        // 3. Calculate price
        int quantity = item.getQuantity() != null ? item.getQuantity() : 1; // default to 1 if null
        double pricePerUnit = productResp.getProductPrice();
        double defaultWeight = productResp.getProductWeight();
        double totalPrice;

        // Use weight-based price if provided and different from master data
        if (item.getWeight() != null && item.getWeight() > 0 && Math.abs(item.getWeight() - defaultWeight) > 0.0001) {
            // Price by actual weight, e.g. buying 1.5kg at unit price per 1kg
            totalPrice = pricePerUnit * (item.getWeight() / defaultWeight);
            logger.info("⚖️ Weight-based pricing: {} x ({} / {}) = {}", pricePerUnit, item.getWeight(), defaultWeight, totalPrice);
        } else {
            // Standard unit price * quantity
            totalPrice = pricePerUnit * quantity;
            logger.info("📦 Unit-based pricing: {} x {} = {}", pricePerUnit, quantity, totalPrice);
        }

        // 4. Build Cart entity
        Cart cartItem = new Cart();
        cartItem.setBarcode(barcode);
        cartItem.setName(productResp.getProductName());
        cartItem.setQuantity(quantity);
        cartItem.setWeight(item.getWeight() != null ? item.getWeight() : defaultWeight); // store the actual weight used
        cartItem.setPrice(totalPrice);
        cartItem.setUserId(userId);

        // 5. Save to DB
        Cart saved = cartRepository.save(cartItem);
        logger.info("✅ Item '{}' added to cart with ID: {}", saved.getName(), saved.getId());

        // 6. Clear barcode from cache (optional, so next scan is new)
        barcodeListenerService.clearLatestBarcode();

        // 7. Update bill via gRPC as before
        BillRequest billRequest = BillRequest.newBuilder()
                .setUsername(userId)
                .setCartId(userId)
                .setTotalPrice(saved.getPrice())
                .build();

        try {
            BillResponse grpcResponse = billUpdateServiceBlockingStub.updateBill(billRequest);
            logger.info("🧾 Bill updated via gRPC: {}", grpcResponse.getStatus());
        } catch (Exception e) {
            logger.error("❌ Failed to update bill via gRPC: {}", e.getMessage(), e);
        } finally {
            logger.info("🧾 Bill update process completed.");
        }

        // Return saved DTO
        CartDTO result = new CartDTO();
        result.setName(saved.getName());
        result.setQuantity(saved.getQuantity());
        result.setPrice(saved.getPrice());
        result.setWeight(saved.getWeight());

        logger.info("✅ Cart item DTO: {}", result);
        return result;

    }


    @Override
    @Transactional
    public CartDTO updateItems(CartDTO item) {

        String userId = extractUsernameFromRequest();

        Optional<Cart> optionalCart = cartRepository.findById(item.getId());

        if (optionalCart.isEmpty()) {
            logger.warn("❌ Item ID {} not found in cart", item.getId());
            throw new IllegalArgumentException("Cart item not found");
        }

        Cart cart = optionalCart.get();

        if (!cart.getUserId().equals(userId)) {
            logger.warn("❌ Unauthorized update attempt for item ID {} by user {}", item.getId(), userId);
            throw new SecurityException("You are not authorized to update this item");
        }

        // === Fetch product details from Product Service (by barcode or cart name) ===
        // Assuming Cart has barcode saved (best), else use name:
        String barcode = cart.getBarcode(); // If you store barcode in Cart entity
        if (barcode == null || barcode.isEmpty()) {
            barcode = cart.getName(); // fallback to product name if barcode not present
        }
        ProductDetailsRequest req = ProductDetailsRequest.newBuilder()
                .setBarcode(barcode)
                .build();
        ProductDetailsResponse productResp;
        try {
            productResp = productDetailsServiceStub.getProductDetails(req);
        } catch (Exception e) {
            logger.error("❌ gRPC call to product service failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch product details for barcode: " + barcode, e);
        }

        if (!productResp.getExists()) {
            logger.warn("❌ Product not found for barcode: {}", barcode);
            throw new IllegalArgumentException("Product not found for barcode: " + barcode);
        }

        // === Calculate price (weight-based or unit-based) ===
        int quantity = item.getQuantity() != null ? item.getQuantity() : 1;
        double pricePerUnit = productResp.getProductPrice();
        double defaultWeight = productResp.getProductWeight();
        double finalWeight = (item.getWeight() != null && item.getWeight() > 0) ? item.getWeight() : defaultWeight;
        double totalPrice;

        // Use weight-based price if custom weight provided
        if (item.getWeight() != null && item.getWeight() > 0 && Math.abs(item.getWeight() - defaultWeight) > 0.0001) {
            totalPrice = pricePerUnit * (item.getWeight() / defaultWeight);
            logger.info("⚖️ Weight-based pricing for update: {} x ({} / {}) = {}", pricePerUnit, item.getWeight(), defaultWeight, totalPrice);
        } else {
            totalPrice = pricePerUnit * quantity;
            logger.info("📦 Unit-based pricing for update: {} x {} = {}", pricePerUnit, quantity, totalPrice);
        }

        // === Update Cart fields ===
        cart.setName(productResp.getProductName());
        cart.setQuantity(quantity);
        cart.setWeight(finalWeight);
        cart.setPrice(totalPrice);

        // Optionally update barcode in Cart if you want (recommended for future-proofing)
        // cart.setBarcode(barcode);

        // 💾 Save updated entity
        Cart updated = cartRepository.save(cart);
        logger.info("✅ Updated cart item ID {} for user {}", updated.getId(), userId);

        // 📡 Call gRPC to update bill
        try {
            BillRequest billRequest = BillRequest.newBuilder()
                    .setUsername(userId)
                    .setCartId(userId)
                    .setTotalPrice(updated.getPrice())
                    .build();

            BillResponse grpcResponse = billUpdateServiceBlockingStub.updateBill(billRequest);
            logger.info("🧾 Bill updated via gRPC: {}", grpcResponse.getStatus());
        } catch (Exception e) {
            logger.error("❌ Failed to update bill via gRPC for item ID {}: {}", updated.getId(), e.getMessage(), e);
        }

        // 📨 Convert to DTO
        CartDTO updatedDto = new CartDTO();
        updatedDto.setId(updated.getId());
        updatedDto.setName(updated.getName());
        updatedDto.setQuantity(updated.getQuantity());
        updatedDto.setPrice(updated.getPrice());
        updatedDto.setWeight(updated.getWeight());

        logger.info("✅ Cart item DTO: {}", updatedDto);
        return updatedDto;
    }

    @Override
    @Transactional
    public void deleteItems(Long id) {

        String userId = extractUsernameFromRequest();

        Cart cart = cartRepository.findById(id).orElseThrow(() -> {
            logger.warn("❌ Item ID {} not found", id);
            return new IllegalArgumentException("Cart item not found");
        });

        if (!cart.getUserId().equals(userId)) {
            logger.warn("❌ Unauthorized delete attempt for item ID {} by user {}", id, userId);
            throw new SecurityException("You are not authorized to delete this item");
        }

        double priceToDeduct = cart.getPrice();
        cartRepository.deleteById(id);
        logger.info("✅ Cart item deleted. Attempting to update bill via gRPC for -{}", priceToDeduct);

        try {
            BillRequest billRequest = BillRequest.newBuilder()
                    .setUsername(userId)
                    .setCartId(userId)
                    .setTotalPrice(-priceToDeduct) // subtract deleted item's price
                    .build();

            BillResponse grpcResponse = billUpdateServiceBlockingStub.updateBill(billRequest);
            logger.info("🧾 Bill updated via gRPC after deletion: {}", grpcResponse.getStatus());
        } catch (Exception e) {
            logger.error("❌ Failed to update bill via gRPC after deleting cart item: {}", e.getMessage(), e);
        }

    }

    @Override
    @Transactional(readOnly = true)
    public CartDTO getItemById(Long id) {

        String userId = extractUsernameFromRequest();

        return cartRepository.findById(id)
                .filter(cart -> cart.getUserId().equals(userId))
                .map(cart -> {
                    CartDTO dto = new CartDTO();
                    dto.setId(cart.getId());
                    dto.setName(cart.getName());
                    dto.setQuantity(cart.getQuantity());
                    dto.setPrice(cart.getPrice());
                    logger.info("✅ Found cart item: {}", dto);
                    return dto;
                })
                .orElseThrow(() -> {
                    logger.warn("❌ Cart item not found or access denied for ID {}", id);
                    return new IllegalArgumentException("Cart item not found or access denied");
                });
    }
}
