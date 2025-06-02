package com.sb.shoppinglistservice.dto;

public class GetShoppingItemsDTO {

    private String itemName;

    private Integer quantity;

    private Double weight;

    private Integer productShelfNumber;

    private Integer productRowNumber;

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public Integer getProductShelfNumber() {
        return productShelfNumber;
    }

    public void setProductShelfNumber(Integer productShelfNumber) {
        this.productShelfNumber = productShelfNumber;
    }

    public Integer getProductRowNumber() {
        return productRowNumber;
    }

    public void setProductRowNumber(Integer productRowNumber) {
        this.productRowNumber = productRowNumber;
    }
}
