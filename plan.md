# PROJECT PLAN: NEXT-GEN POS SYSTEM 2026 (OFFLINE-FIRST)
**Integration:** Botble CMS (Laravel) Backend  
**Target Platform:** Ubuntu (Primary), Windows  
**Tech Stack:** Flutter (Dart) + SQLite (Drift)

---

## 1. TỔNG QUAN DỰ ÁN (EXECUTIVE SUMMARY)
*   **Mục tiêu:** Xây dựng ứng dụng POS bán hàng đa năng, hoạt động offline ổn định, tuân thủ quy định Thuế 2026 (Ký số từ xa/HĐĐT).
*   **Triết lý thiết kế:** "One App, Multi-Business" (Một ứng dụng cho nhiều nghiệp vụ). Sử dụng cơ chế **Feature Flags** để bật/tắt các module chuyên sâu (F&B, Dược phẩm) mà không làm nặng phần lõi.
*   **Vai trò của Botble CMS:** Đóng vai trò Backend quản trị trung tâm (Master Data Management), cấu hình hệ thống và báo cáo tổng hợp. Logic bán hàng phức tạp được xử lý tại Client (Flutter).

---

## 2. KIẾN TRÚC KỸ THUẬT (SYSTEM ARCHITECTURE)

### A. Client Side (POS Device)
*   **Framework:** Flutter (Dart).
*   **Database:** SQLite (Library: `Drift` - Reactive & Type-safe).
*   **State Management:** BLoC (Business Logic Component) hoặc Riverpod.
*   **Build Output:**
    *   **Ubuntu:** AppImage (Không cần cài đặt, chạy ngay).
    *   **Windows:** .exe (Self-contained).
*   **Offline Mechanism:** Sync Queue (Hàng đợi đồng bộ). Mọi tác vụ ghi dữ liệu đều lưu vào SQLite trước, sau đó Background Service mới đẩy lên Server.

### B. Server Side (Botble CMS)
*   **Core:** Laravel Framework.
*   **Database:** MySQL/PostgreSQL.
*   **API Protocol:** RESTful JSON.
*   **Nhiệm vụ:**
    *   Lưu trữ danh mục, sản phẩm, khách hàng, kho tổng.
    *   Nhận đơn hàng, phiếu kho từ POS.
    *   Quản lý cấu hình Module (Feature Flags) cho từng chi nhánh.

---

## 3. CHIẾN LƯỢC MODULE HÓA (FEATURE TOGGLES)
Do Botble không chuyên về F&B, hệ thống sẽ sử dụng cờ tính năng để bật/tắt logic xử lý tại Client, giữ cho Backend sạch sẽ.

### Các Feature Flags chính:
1.  **`is_fnb_enabled` (Chế độ F&B):**
    *   *Bật:* Hiển thị Sơ đồ bàn, Tab Bếp/Bar, sử dụng logic trừ kho theo định mức (BOM).
    *   *Tắt:* Ẩn sơ đồ bàn, dùng giao diện bán lẻ, trừ kho trực tiếp.
2.  **`is_batch_tracking_enabled` (Chế độ Lô/Date):**
    *   *Bật:* Bắt buộc nhập Lô/Hạn sử dụng khi nhập hàng. Áp dụng thuật toán FEFO khi xuất kho.
    *   *Tắt:* Chỉ quản lý số lượng tổng (`quantity_on_hand`).
3.  **`is_multi_warehouse` (Đa kho/Chuỗi):**
    *   *Bật:* Kích hoạt module Chuyển kho, check tồn kho chi nhánh khác.

---

## 4. THIẾT KẾ CƠ SỞ DỮ LIỆU CLIENT (SQLITE SCHEMA)

### Nhóm 1: Sản phẩm & Cấu hình (Master Data)
*   **`Settings`**: Lưu `feature_flags`, thông tin cửa hàng, cấu hình máy in.
*   **`Products`**:
    *   `id`, `sku`, `name`, `price`, `tax_rate`.
    *   `type`: 'STANDARD' (Hàng hóa), 'SERVICE' (Dịch vụ), 'COMPOSITE' (Combo/Món ăn).
    *   `attributes_json`: Lưu Size/Màu/IMEI dưới dạng JSON.
*   **`ProductFormulas` (BOM)**:
    *   `parent_product_id`, `child_product_id`, `quantity`. (Dùng cho F&B).
*   **`ProductBarcodes`**: 1 sản phẩm n - mã vạch (Mã thùng, mã lẻ).

### Nhóm 2: Kho hàng (Inventory Core)
*   **`InventoryStock`**: Tồn kho tổng hợp.
    *   `product_id`, `warehouse_id`, `quantity_on_hand`, `mac_price` (Giá vốn bình quân).
*   **`InventoryBatches`**: Tồn kho chi tiết (Khi bật module Batch).
    *   `product_id`, `batch_number`, `expiry_date`, `quantity`.
*   **`StockCard`**: Lịch sử giao dịch (Thẻ kho).
    *   `transaction_type` (SALE, INBOUND, OUTBOUND, TRANSFER), `change`, `balance_after`, `reference_id`.

### Nhóm 3: Giao dịch (Transactions)
*   **`Orders` & `OrderDetails`**: Đơn bán hàng.
*   **`InventoryVouchers` & `VoucherDetails`**: Phiếu Nhập/Xuất/Chuyển.
*   **`SyncQueue`**:
    *   `id`, `api_endpoint`, `payload_json`, `status` (PENDING, FAILED), `retry_count`.

---

## 5. CHỨC NĂNG CHI TIẾT (FUNCTIONAL REQUIREMENTS)

### A. Module Bán hàng (Sales)
*   **Scanner Logic:** Sử dụng `RawKeyboardListener` để bắt sự kiện từ máy quét mã vạch (HID mode) mà không cần focus vào ô input.
*   **Smart Search:** Tìm kiếm theo Tên, SKU, hoặc Mã vạch.
*   **Xử lý Giá:** Tự động áp dụng giá sỉ/lẻ, khuyến mãi (nếu có logic sync từ Botble).
*   **Thanh toán:** Tiền mặt, QR Code động, Thẻ.

### B. Module Kho (Inventory Logic)
*   **Logic Xuất kho:**
    *   Nếu `type == STANDARD`: Trừ `InventoryStock`.
    *   Nếu `type == COMPOSITE` (F&B): Query `ProductFormulas` -> Trừ nguyên liệu tương ứng.
    *   Nếu `is_batch_tracking_enabled`: Áp dụng thuật toán **FEFO** (Hết hạn trước xuất trước) để trừ trong `InventoryBatches`.
*   **Quy trình Chứng từ:**
    *   Nhập hàng (Purchase Receipt): Tăng kho, tính lại giá vốn MAC.
    *   Chuyển kho (Transfer): Quy trình 2 bước (Xuất tại kho đi -> Chờ -> Nhập tại kho đến).
    *   Kiểm kê (Stocktake): Điều chỉnh kho theo số lượng thực tế.

### C. Module Thuế & In ấn (Tax & Hardware)
*   **Hóa đơn điện tử (2026):**
    *   Tích hợp API **Ký số từ xa** (VNPT/Viettel SmartCA) - Không cần USB Token phần cứng.
    *   Tự động tính thuế suất theo từng dòng hàng.
    *   Gửi dữ liệu lên CQT, nhận Mã CQT để in ra bill.
*   **In ấn (Printing):**
    *   **Hóa đơn:** Sử dụng lệnh ESC/POS (Raw) qua USB/LAN. Template tùy chỉnh.
    *   **Phiếu Kho:** Render ra PDF (A4/A5) và in qua driver hệ điều hành.

---

## 6. YÊU CẦU API (BOTBLE SIDE)
Cần phát triển Plugin API cho Botble để phục vụ các endpoint sau:

1.  **Sync Initial (`GET /api/pos/init`)**:
    *   Input: `device_id`, `store_id`.
    *   Output: `feature_flags`, `products`, `categories`, `customers`, `tax_settings`.
2.  **Sync Orders (`POST /api/pos/orders`)**:
    *   Nhận danh sách đơn hàng offline đẩy lên.
3.  **Sync Inventory (`POST /api/pos/inventory`)**:
    *   Nhận các phiếu Nhập/Xuất/Kiểm kê.
4.  **Lookup Customer (`GET /api/pos/customer/search`)**:
    *   Tìm khách hàng online nếu local không có.

---

## 7. LỘ TRÌNH PHÁT TRIỂN (ROADMAP)

### Phase 1: Foundation & Retail (Tháng 1-2)
*   Dựng Project Flutter, cấu hình Drift (SQLite).
*   Xây dựng API cơ bản trên Botble.
*   Hoàn thiện luồng: Đồng bộ SP -> Quét mã vạch -> Bán hàng -> In Bill (ESC/POS) -> Sync Order.
*   Đóng gói AppImage cho Ubuntu.

### Phase 2: Advanced Inventory & Tax (Tháng 3-4)
*   Implement bảng `InventoryBatches`, `StockCard`.
*   Logic FEFO và quản lý hạn sử dụng.
*   Module Phiếu Nhập/Xuất/Chuyển kho và in PDF.
*   Tích hợp API Ký số từ xa & Hóa đơn điện tử.

### Phase 3: F&B Module (Tháng 5)
*   Logic `ProductFormulas` (BOM).
*   Giao diện Sơ đồ bàn (Table Map).
*   Logic In bếp/In bar (Split printing).
*   Tối ưu hóa performance và kiểm thử trên thiết bị thật.

---

## 8. GHI CHÚ TRIỂN KHAI (DEPLOYMENT NOTES)
*   **Ubuntu Setup:**
    *   Cần set quyền truy cập USB cho user: `sudo usermod -aG lp $USER`.
    *   AppImage cần cấp quyền thực thi: `chmod +x PosApp.AppImage`.
*   **Update Mechanism:**
    *   App tự động check version từ Botble API.
    *   Nếu có bản mới -> Tải AppImage mới về -> Thông báo người dùng khởi động lại.