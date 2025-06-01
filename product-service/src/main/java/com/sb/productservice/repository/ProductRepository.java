package com.sb.productservice.repository;

import com.sb.productservice.model.Products;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProductRepository extends JpaRepository<Products, UUID> {
}
