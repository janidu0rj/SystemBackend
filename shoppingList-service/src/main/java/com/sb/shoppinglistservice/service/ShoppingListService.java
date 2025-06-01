package com.sb.shoppinglistservice.service;

import com.sb.shoppinglistservice.dto.ShoppingItemDTO;

import java.util.List;

public interface ShoppingListService {

    String addItem(ShoppingItemDTO itemDTO);

    String updateItem(ShoppingItemDTO itemDTO);

    List<ShoppingItemDTO> getItems();

    void deleteItem(String itemId);

    void deleteAllItems();
}
