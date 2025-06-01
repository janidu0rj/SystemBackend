package com.sb.shoppinglistservice.service;

import com.sb.customerservice.grpc.GetUsernameRequest;
import com.sb.customerservice.grpc.GetUsernameResponse;
import com.sb.customerservice.grpc.UserInfoServiceGrpc;
import com.sb.shoppinglistservice.dto.ShoppingItemDTO;
import com.sb.shoppinglistservice.model.ShoppingItem;
import com.sb.shoppinglistservice.repository.ShoppingItemRepository;
import jakarta.servlet.http.HttpServletRequest;
import net.devh.boot.grpc.client.inject.GrpcClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ShoppingListServiceImpl implements ShoppingListService {

    private static final Logger log = LoggerFactory.getLogger(ShoppingListServiceImpl.class);

    private final ShoppingItemRepository shoppingItemRepository;

    private final HttpServletRequest request;

    public ShoppingListServiceImpl(ShoppingItemRepository shoppingItemRepository,
                                   HttpServletRequest request) {
        this.shoppingItemRepository = shoppingItemRepository;
        this.request = request;
    }

    @GrpcClient("customer-service")
    private UserInfoServiceGrpc.UserInfoServiceBlockingStub userInfoStub;

    /** Helper to extract username from JWT in Authorization header. */
    private String extractUsernameFromRequest() {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.error("❌ Missing or invalid Authorization header");
            throw new SecurityException("Missing or invalid Authorization header");
        }
        String jwt = authHeader.substring(7);
        try {
            GetUsernameRequest grpcRequest = GetUsernameRequest.newBuilder().setJwt(jwt).build();
            GetUsernameResponse grpcResponse = userInfoStub.getUsername(grpcRequest);
            String username = grpcResponse.getUsername();
            if (username.isEmpty()) {
                log.error("❌ Username extraction failed via gRPC for JWT: {}", jwt);
                throw new SecurityException("Unable to extract username from JWT");
            }
            return username;
        } catch (Exception e) {
            log.error("❌ gRPC call failed while extracting username: {}", e.getMessage(), e);
            throw new SecurityException("Error extracting username from JWT via gRPC", e);
        }
    }


    @Override
    @Transactional
    public String addItem(ShoppingItemDTO itemDTO) {

        log.info("🛒 Adding shopping item: {}", itemDTO.getItemName());

        String username = extractUsernameFromRequest();

        try {
            ShoppingItem item = new ShoppingItem();
            item.setUsername(username);
            item.setItemName(itemDTO.getItemName());
            item.setQuantity(itemDTO.getQuantity());
            item.setWeight(itemDTO.getWeight());

            ShoppingItem saved = shoppingItemRepository.save(item);
            log.info("✅ Item '{}' added for user '{}'", saved.getItemName(), saved.getUsername());
            return "Item added successfully with ID: " + saved.getId();
        } catch (Exception e) {
            log.error("❌ Failed to add item for user {}: {}", username, e.getMessage(), e);
            throw new RuntimeException("Failed to add shopping item", e);
        }
    }

    @Override
    @Transactional
    public String updateItem(ShoppingItemDTO itemDTO) {

        log.info("✏️ Attempting to update item with ID: {}", itemDTO.getId());

        String username = extractUsernameFromRequest();

        try {
            ShoppingItem item = shoppingItemRepository.findById(itemDTO.getId())
                    .orElseThrow(() -> {
                        log.warn("❌ Item with ID {} not found", itemDTO.getId());
                        return new IllegalArgumentException("Item not found with ID: " + itemDTO.getId());
                    });

            if (!item.getUsername().equals(username)) {
                log.warn("❌ Unauthorized update attempt by user '{}' on item ID {}", username, itemDTO.getId());
                throw new SecurityException("Unauthorized to update this item");
            }

            item.setItemName(itemDTO.getItemName());
            item.setQuantity(itemDTO.getQuantity());
            item.setWeight(itemDTO.getWeight());

            shoppingItemRepository.save(item);
            log.info("✅ Item ID {} updated successfully for user '{}'", itemDTO.getId(), username);
            return "Item updated successfully with ID: " + itemDTO.getId();
        } catch (Exception e) {
            log.error("❌ Failed to update item ID {} for user {}: {}", itemDTO.getId(), username, e.getMessage(), e);
            throw new RuntimeException("Failed to update shopping item", e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShoppingItemDTO> getItems() {
        String username = extractUsernameFromRequest();
        log.info("📥 Fetching shopping items for user: {}", username);

        try {
            List<ShoppingItem> items = shoppingItemRepository.findAll()
                    .stream()
                    .filter(item -> item.getUsername().equals(username))
                    .toList();

            List<ShoppingItemDTO> dtoList = items.stream().map(item -> {
                ShoppingItemDTO dto = new ShoppingItemDTO();
                dto.setId(item.getId());
                dto.setItemName(item.getItemName());
                dto.setQuantity(item.getQuantity());
                dto.setWeight(item.getWeight());
                return dto;
            }).toList();

            log.info("✅ Found {} item(s) for user {}", dtoList.size(), username);
            return dtoList;
        } catch (Exception e) {
            log.error("❌ Failed to fetch items for user {}: {}", username, e.getMessage(), e);
            throw new RuntimeException("Failed to fetch shopping items", e);
        }
    }


    @Override
    @Transactional
    public void deleteItem(String itemId) {
        String username = extractUsernameFromRequest();
        log.info("🗑️ Attempting to delete item with ID {} for user {}", itemId, username);

        try {
            Long id = Long.parseLong(itemId);
            ShoppingItem item = shoppingItemRepository.findById(id)
                    .orElseThrow(() -> {
                        log.warn("❌ Item with ID {} not found", itemId);
                        return new IllegalArgumentException("Item not found");
                    });

            if (!item.getUsername().equals(username)) {
                log.warn("❌ Unauthorized attempt to delete item ID {} by user {}", itemId, username);
                throw new SecurityException("You are not authorized to delete this item");
            }

            shoppingItemRepository.deleteById(id);
            log.info("✅ Item with ID {} successfully deleted for user {}", id, username);

        } catch (NumberFormatException e) {
            log.error("❌ Invalid ID format: {}", itemId, e);
            throw new IllegalArgumentException("Invalid ID format", e);
        } catch (Exception e) {
            log.error("❌ Failed to delete item ID {} for user {}: {}", itemId, username, e.getMessage(), e);
            throw new RuntimeException("Failed to delete shopping item", e);
        }
    }

    @Override
    @Transactional
    public void deleteAllItems() {
        String username = extractUsernameFromRequest();
        log.info("🧹 Attempting to delete all items for user: {}", username);

        try {
            List<ShoppingItem> items = shoppingItemRepository.findAll()
                    .stream()
                    .filter(item -> item.getUsername().equals(username))
                    .toList();

            if (items.isEmpty()) {
                log.info("📭 No items found to delete for user: {}", username);
                return;
            }

            shoppingItemRepository.deleteAll(items);
            log.info("✅ Deleted {} item(s) for user: {}", items.size(), username);

        } catch (Exception e) {
            log.error("❌ Failed to delete all items for user {}: {}", username, e);
            throw new RuntimeException("Failed to delete all shopping items", e);
        }
    }
}
