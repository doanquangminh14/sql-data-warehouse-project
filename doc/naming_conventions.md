# 🏷️ Quy ước Đặt tên (Naming Conventions)

Tài liệu này quy định các chuẩn mực và quy tắc đặt tên cho các đối tượng trong Data Warehouse bao gồm: Schema, Bảng (Table), Khung nhìn (View), Cột (Column) và Thủ tục lưu trữ (Stored Procedure).

---

## 📌 Mục lục

1. [Nguyên tắc chung (General Principles)](#1-nguyên-tắc-chung-general-principles)
2. [Quy ước đặt tên Bảng & View (Table & View Naming)](#2-quy-ước-đặt-tên-bảng--view-table--view-naming)
   - [Tầng Bronze (Bronze Layer)](#tầng-bronze-bronze-layer)
   - [Tầng Silver (Silver Layer)](#tầng-silver-silver-layer)
   - [Tầng Gold (Gold Layer)](#tầng-gold-gold-layer)
   - [Bảng tra cứu tiền tố tầng Gold](#bảng-tra-cứu-tiền-tố-tầng-gold)
3. [Quy ước đặt tên Cột (Column Naming)](#3-quy-ước-đặt-tên-cột-column-naming)
   - [Khóa thay thế (Surrogate Keys)](#khóa-thay-thế-surrogate-keys)
   - [Cột kỹ thuật & Metadata (Technical Columns)](#cột-kỹ-thuật--metadata-technical-columns)
4. [Quy ước đặt tên Stored Procedure](#4-quy-ước-đặt-tên-stored-procedure)

---

## 1. Nguyên tắc chung (General Principles)

- **Cú pháp đặt tên:** Sử dụng kiểu `snake_case` (chữ cái thường và dấu gạch dưới `_` để phân cách các từ).
- **Ngôn ngữ:** Sử dụng tiếng Anh cho tất cả tên đối tượng kỹ thuật (tên bảng, view, procedure, cột).
- **Tránh từ khóa dành riêng:** Không sử dụng các từ khóa hệ thống SQL (SQL Reserved Words) làm tên đối tượng.

---

## 2. Quy ước đặt tên Bảng & View (Table & View Naming)

### Tầng Bronze (Bronze Layer)
- Tên bảng bắt đầu bằng tên hệ thống nguồn (`crm`, `erp`), theo sau là tên thực thể/bảng gốc nguyên bản từ file nguồn:
- **Cú pháp:** `bronze.<sourcesystem>_<entity>`
  - `<sourcesystem>`: Tên hệ thống nguồn (ví dụ: `crm`, `erp`).
  - `<entity>`: Tên thực thể/tập tin gốc từ nguồn.
  - *Ví dụ:* `bronze.crm_cust_info` (Dữ liệu khách hàng từ CRM), `bronze.erp_cust_az12` (Dữ liệu khách hàng từ ERP).

### Tầng Silver (Silver Layer)
- Tương tự tầng Bronze, tên bảng bắt đầu bằng tên hệ thống nguồn để đảm bảo theo dõi rõ nguồn gốc dữ liệu đã qua làm sạch:
- **Cú pháp:** `silver.<sourcesystem>_<entity>`
  - `<sourcesystem>`: Tên hệ thống nguồn (ví dụ: `crm`, `erp`).
  - `<entity>`: Tên bảng sau khi đã chuẩn hóa và làm sạch.
  - *Ví dụ:* `silver.crm_cust_info`, `silver.erp_px_cat_g1v2`.

### Tầng Gold (Gold Layer)
- Sử dụng các tên có ý nghĩa nghiệp vụ kinh doanh rõ ràng, bắt đầu bằng tiền tố phân loại (`dim_`, `fact_`):
- **Cú pháp:** `gold.<category>_<entity>`
  - `<category>`: Thể hiện vai trò của bảng/view (`dim` cho Dimension, `fact` cho Fact).
  - `<entity>`: Tên thực thể nghiệp vụ (ví dụ: `customers`, `products`, `sales`).
  - *Ví dụ:*
    - `gold.dim_customers` → Bảng chiều thông tin khách hàng.
    - `gold.dim_products` → Bảng chiều thông tin sản phẩm.
    - `gold.fact_sales` → Bảng sự kiện giao dịch bán hàng.

#### Bảng tra cứu tiền tố tầng Gold:

| Tiền tố (Prefix) | Ý nghĩa (Meaning) | Ví dụ (Example) |
| :--- | :--- | :--- |
| `dim_` | Bảng chiều (Dimension view/table) | `dim_customers`, `dim_products` |
| `fact_` | Bảng sự kiện/giao dịch (Fact view/table) | `fact_sales` |
| `report_` | Bảng/View báo cáo tổng hợp (Report view/table) | `report_monthly_sales`, `report_customers` |

---

## 3. Quy ước đặt tên Cột (Column Naming)

### Khóa thay thế (Surrogate Keys)
- Tất cả các khóa chính (PK) hoặc khóa ngoại (FK) dạng surrogate key trong tầng Gold phải kết thúc bằng hậu tố `_key`:
- **Cú pháp:** `<entity>_key`
  - `<entity>`: Tên thực thể liên quan (ví dụ: `customer`, `product`).
  - `_key`: Hậu tố xác định đây là khóa thay thế.
  - *Ví dụ:* `customer_key` trong `gold.dim_customers`, `product_key` trong `gold.dim_products`.

### Cột kỹ thuật & Metadata (Technical Columns)
- Các cột metadata kỹ thuật do hệ thống ETL sinh ra phải bắt đầu bằng tiền tố `dwh_`:
- **Cú pháp:** `dwh_<column_name>`
  - `dwh`: Tiền tố dành riêng cho dữ liệu kỹ thuật kho dữ liệu.
  - `<column_name>`: Tên mô tả mục đích của cột.
  - *Ví dụ:* `dwh_create_date` → Cột ghi nhận thời điểm nạp dòng dữ liệu vào kho.

---

## 4. Quy ước đặt tên Stored Procedure

- Toàn bộ Stored Procedure phục vụ nạp và xử lý dữ liệu phải tuân theo quy tắc:
- **Cú pháp:** `<schema>.load_<layer>`
  - `<schema>`: Schema tương ứng (`bronze`, `silver`).
  - `<layer>`: Tầng dữ liệu được nạp (`bronze`, `silver`).
  - *Ví dụ:*
    - `bronze.load_bronze` → Thủ tục nạp dữ liệu từ nguồn vào tầng Bronze.
    - `silver.load_silver` → Thủ tục làm sạch và nạp dữ liệu từ Bronze vào Silver.
