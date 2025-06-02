package com.sb.billservice.controller;

import com.sb.billservice.dto.PayBillDTO;
import com.sb.billservice.dto.ViewBillDTO;
import com.sb.billservice.service.BillService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/bill")
public class BillController {

    private static final Logger logger = LoggerFactory.getLogger(BillController.class);
    private final BillService billService;

    public BillController(BillService billService) {
        this.billService = billService;
    }

    // GET /bill/view
    @GetMapping("/customer/view")
    public ResponseEntity<ViewBillDTO> viewCurrentBill() {
        logger.info("📋 API call to view bill");
        ViewBillDTO bill = billService.getBill();
        return ResponseEntity.ok(bill);
    }

    // POST /bill/pay
    @PostMapping("/auth/pay")
    public ResponseEntity<String> payBill(@Valid @RequestBody PayBillDTO payBillDTO) {
        logger.info("💰 API call to pay bill ID: {}", payBillDTO.getBillId());
        String response = billService.payBill(payBillDTO);
        return ResponseEntity.ok(response);
    }

}
