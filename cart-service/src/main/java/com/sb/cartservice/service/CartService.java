package com.sb.cartservice.service;

import com.sb.cartservice.dto.CartDTO;
import java.util.List;

public interface CartService {

    List<CartDTO> getAllItems();

    CartDTO addItems(CartDTO item);

    CartDTO updateItems(CartDTO item);

    void deleteItems(Long id);

    CartDTO getItemById(Long id);
}
