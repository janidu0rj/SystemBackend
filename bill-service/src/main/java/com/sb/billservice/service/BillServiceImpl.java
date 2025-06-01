package com.sb.billservice.service;

import com.sb.backupservice.grpc.*;
import com.sb.billservice.dto.PayBillDTO;
import com.sb.billservice.dto.ViewBillDTO;
import com.sb.billservice.model.Bill;
import com.sb.billservice.model.BillStatus;
import com.sb.billservice.repository.BillRepository;
import net.devh.boot.grpc.client.inject.GrpcClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class BillServiceImpl implements BillService {

    private static final Logger logger = LoggerFactory.getLogger(BillServiceImpl.class);

    private final BillRepository billRepository;

    public BillServiceImpl(BillRepository billRepository) {
        this.billRepository = billRepository;
    }

    @GrpcClient("bill-backup-service")
    private BillBackupServiceGrpc.BillBackupServiceBlockingStub billBackupService;

    @Override
    @Transactional(readOnly = true)
    public ViewBillDTO getBill() {
        String username = "user-123"; // 🔐 Later extract from JWT

        logger.info("🔍 Fetching IN_PROGRESS bill for user: {}", username);

        // Find bill with status IN_PROGRESS for the user
        return billRepository.findByUsernameAndStatus(username, BillStatus.IN_PROGRESS)
                .map(bill -> {
                    ViewBillDTO dto = new ViewBillDTO();
                    dto.setUsername(bill.getUsername());
                    dto.setBillId(bill.getId());
                    dto.setTotalAmount(String.format("%.2f", bill.getTotalPrice()));
                    dto.setBillStatus(bill.getStatus());
                    logger.info("✅ Found bill for user: {}", username);
                    return dto;
                })
                .orElseThrow(() -> {
                    logger.warn("❌ No IN_PROGRESS bill found for user: {}", username);
                    return new IllegalArgumentException("No IN_PROGRESS bill found for user: " + username);
                });
    }

    @Override
    @Transactional
    public String payBill(PayBillDTO payBillDTO) {

        String approvedBy = "authorized-user"; // 🔐 Replace with JWT username later
        Long billId = payBillDTO.getBillId();
        String username = payBillDTO.getUsername();

        logger.info("💳 Attempting to pay bill ID {} for user {}", billId, username);

        Bill bill = billRepository.findById(billId)
                .filter(b -> b.getUsername().equals(username))
                .orElseThrow(() -> {
                    logger.warn("❌ Bill not found for ID {} and user {}", billId, username);
                    return new IllegalArgumentException("Bill not found for the specified user and ID.");
                });

        if (bill.getStatus() == BillStatus.PAID) {
            logger.warn("❌ Bill ID {} is already marked as PAID", billId);
            throw new IllegalStateException("Bill is already paid.");
        }

        // ✅ Update payment details
        bill.setStatus(BillStatus.PAID);
        bill.setPaymentMethod(payBillDTO.getPaymentMethod());
        bill.setApprovedBy(approvedBy);
        bill.setDate(LocalDateTime.now());

        billRepository.save(bill);
        logger.info("✅ Bill ID {} marked as PAID by {}", billId, approvedBy);

        // 📦 Prepare gRPC backup request
        BillRequest grpcRequest = BillRequest.newBuilder()
                .setId(bill.getId())
                .setCartId(bill.getCarId())
                .setUsername(bill.getUsername())
                .setTotalPrice(bill.getTotalPrice())
                .setDate(bill.getDate().toString())
                .setApprovedBy(bill.getApprovedBy() != null ? bill.getApprovedBy() : "")
                .setStatus(BILL_STATUS.valueOf(bill.getStatus().name()))
                .setPaymentMethod(PAYMENT_METHOD.valueOf(bill.getPaymentMethod().name()))
                .build();

        try {
            BillResponse grpcResponse = billBackupService.saveBill(grpcRequest);
            logger.info("📡 Backup updated successfully via gRPC: {}", grpcResponse.getStatus());
        } catch (Exception e) {
            logger.error("❌ Failed to update bill in backup database via gRPC", e);
            throw new RuntimeException("Backup update failed: " + e.getMessage(), e);
        }


        return "✅ Bill paid successfully for bill ID: " + billId;
    }
}
