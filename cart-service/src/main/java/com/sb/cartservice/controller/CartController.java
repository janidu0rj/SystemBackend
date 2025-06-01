package com.sb.cartservice.controller;

import com.sb.cartservice.dto.CartDTO;
import com.sb.cartservice.service.CartService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    // 🔍 Get all cart items for the current user
    @GetMapping("/all")
    public ResponseEntity<List<CartDTO>> getAllItems() {
        List<CartDTO> items = cartService.getAllItems();
        return ResponseEntity.ok(items);
    }

    // ➕ Add an item to the cart
    @PostMapping("/add")
    public ResponseEntity<CartDTO> addItem(@RequestBody @Valid CartDTO item) {
        CartDTO saved = cartService.addItems(item);
        return ResponseEntity.ok(saved);
    }

    // 🔄 Update an existing cart item
    @PutMapping("/update")
    public ResponseEntity<CartDTO> updateItem(@RequestBody @Valid CartDTO item) {
        CartDTO updated = cartService.updateItems(item);
        return ResponseEntity.ok(updated);
    }

    // ❌ Delete an item from the cart
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteItem(@PathVariable Long id) {
        cartService.deleteItems(id);
        return ResponseEntity.ok("Item deleted successfully with ID: " + id);
    }

    // 🔍 Get a single item by ID
    @GetMapping("/{id}")
    public ResponseEntity<CartDTO> getItemById(@PathVariable Long id) {
        CartDTO item = cartService.getItemById(id);
        return ResponseEntity.ok(item);
    }

}
