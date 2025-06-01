package com.sb.productservice.controller;

import com.sb.productservice.dto.AddProductDTO;
import com.sb.productservice.dto.GetProductDTO;
import com.sb.productservice.dto.UpdateProductDTO;
import com.sb.productservice.model.Products;
import com.sb.productservice.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/product")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    // ✅ Add new product (barcode fetched from IoT Core)
    @PostMapping("/auth/add")
    public ResponseEntity<String> addProduct(@RequestBody @Valid AddProductDTO dto) {
        String response = productService.addProduct(dto);
        return ResponseEntity.ok(response);
    }

    // ✅ Update existing product by barcode
    @PutMapping("/auth/update")
    public ResponseEntity<String> updateProduct(@RequestBody @Valid UpdateProductDTO dto) {
        String response = productService.updateProduct(dto);
        return ResponseEntity.ok(response);
    }

    // ✅ Delete product by barcode
    @DeleteMapping("/auth/delete")
    public ResponseEntity<String> deleteProduct(@RequestParam String barcode) {
        String response = productService.deleteProduct(barcode);
        return ResponseEntity.ok(response);
    }

    // ✅ Get a product using the last scanned barcode
    @GetMapping("/all/get")
    public ResponseEntity<GetProductDTO> getProductByBarcode() {
        GetProductDTO product = productService.getProductByBarcode();
        return ResponseEntity.ok(product);
    }

    // ✅ Get all products
    @GetMapping("/all/all")
    public ResponseEntity<List<GetProductDTO>> getAllProducts() {
        List<GetProductDTO> list = productService.getAllProducts();
        return ResponseEntity.ok(list);
    }

    // ✅ Get products by category
    @GetMapping("/all/by-category")
    public ResponseEntity<List<GetProductDTO>> getByCategory(@RequestParam String category) {
        List<GetProductDTO> list = productService.getProductsByCategory(category);
        return ResponseEntity.ok(list);
    }

    // ✅ Get products by brand
    @GetMapping("/all/by-brand")
    public ResponseEntity<List<GetProductDTO>> getByBrand(@RequestParam String brand) {
        List<GetProductDTO> list = productService.getProductsByBrand(brand);
        return ResponseEntity.ok(list);
    }

}
