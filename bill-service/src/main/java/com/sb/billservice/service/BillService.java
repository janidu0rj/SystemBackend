package com.sb.billservice.service;

import com.sb.billservice.dto.PayBillDTO;
import com.sb.billservice.dto.ViewBillDTO;

public interface BillService {

    ViewBillDTO getBill();

    String payBill(PayBillDTO payBillDTO);

}
