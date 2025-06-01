package com.sb.cartservice.service;

import com.sb.billservice.grpc.BillRequest;
import com.sb.billservice.grpc.BillResponse;
import com.sb.billservice.grpc.BillUpdateServiceGrpc;
import com.sb.cartservice.dto.CartDTO;
import com.sb.cartservice.model.Cart;
import com.sb.cartservice.repository.CartRepository;
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
    private static final Logger logger = LoggerFactory.getLogger(CartServiceImpl.class);

    public CartServiceImpl(CartRepository cartRepository) {
        this.cartRepository = cartRepository;
    }

    @GrpcClient("bill-update-service")
    private BillUpdateServiceGrpc.BillUpdateServiceBlockingStub billUpdateServiceBlockingStub;

    @Override
    @Transactional(readOnly = true)
    public List<CartDTO> getAllItems() {

        // 🔒 Dummy user ID for now; later replace with JWT-based user identification
        String userId = "user-123"; // Dummy user ID, later replace with JWT-based user identification
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

        // Dummy userId (in real app, get from JWT or context)
        String userId = "user-123";

        // Build Cart entity
        Cart cartItem = new Cart();
        cartItem.setName(item.getName());
        cartItem.setQuantity(item.getQuantity());
        cartItem.setPrice(item.getPrice());
        cartItem.setUserId(userId);

        // Save to DB
        Cart saved = cartRepository.save(cartItem);
        logger.info("✅ Item added to cart with ID: {}", saved.getId());

        // Prepare gRPC bill update request
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
        result.setId(saved.getId());
        result.setName(saved.getName());
        result.setQuantity(saved.getQuantity());
        result.setPrice(saved.getPrice());

        logger.info("✅ Cart item DTO: {}", result);
        return result;

    }


    @Override
    @Transactional
    public CartDTO updateItems(CartDTO item) {

        String userId = "user-123"; // 🔒 Dummy for now, replace with JWT-extracted ID later
        logger.info("🔄 Attempting to update item ID {} for user {}", item.getId(), userId);

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

        // ✅ Update fields
        cart.setName(item.getName());
        cart.setQuantity(item.getQuantity());
        cart.setPrice(item.getPrice());

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

        logger.info("✅ Cart item DTO: {}", updatedDto);
        return updatedDto;
    }

    @Override
    @Transactional
    public void deleteItems(Long id) {

        String userId = "user-123"; // Replace with JWT later
        logger.info("🗑️ Attempting to delete cart item ID {} for user {}", id, userId);

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
        String userId = "user-123"; // 🔐 Dummy user ID for now

        logger.info("🔍 Fetching cart item by ID {} for user {}", id, userId);

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
