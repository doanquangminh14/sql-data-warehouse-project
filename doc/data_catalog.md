# 📖 Danh mục Dữ liệu Tầng Gold (Data Catalog for Gold Layer)

## 📌 Tổng quan (Overview)
Tầng **Gold (Gold Layer)** là tầng dữ liệu phục vụ trực tiếp cho nghiệp vụ và phân tích kinh doanh, được cấu trúc theo mô hình hình sao (**Star Schema**) gồm các **bảng chiều (Dimension tables)** và **bảng sự kiện (Fact tables)** tối ưu hóa cho báo cáo BI & Analytics.

---

### 1. **gold.dim_customers**
- **Mục đích:** Lưu trữ thông tin chi tiết về khách hàng, được làm giàu với dữ liệu nhân khẩu học (ngày sinh, giới tính) và vị trí địa lý (quốc gia).
- **Danh sách cột:**

| Tên Cột (Column Name) | Kiểu Dữ Liệu (Data Type) | Mô Tả (Description) |
| :--- | :--- | :--- |
| `customer_key` | `INT` | Khóa thay thế (Surrogate Key) định danh duy nhất mỗi bản ghi khách hàng trong bảng Dimension. |
| `customer_id` | `INT` | Mã định danh số duy nhất của khách hàng từ hệ thống CRM gốc. |
| `customer_number` | `NVARCHAR(50)` | Mã định danh dạng chuỗi (`cst_key`) dùng để theo dõi và liên kết với hệ thống ERP. |
| `first_name` | `NVARCHAR(50)` | Tên của khách hàng. |
| `last_name` | `NVARCHAR(50)` | Họ và tên đệm của khách hàng. |
| `country` | `NVARCHAR(50)` | Quốc gia cư trú của khách hàng (ví dụ: 'Australia', 'United States') từ ERP. |
| `marital_status` | `NVARCHAR(50)` | Tình trạng hôn nhân đã được chuẩn hóa (ví dụ: 'Married', 'Single'). |
| `gender` | `NVARCHAR(50)` | Giới tính khách hàng đã chuẩn hóa ('Male', 'Female', 'n/a'), ưu tiên CRM và fallback ERP. |
| `birthdate` | `DATE` | Ngày sinh của khách hàng, định dạng YYYY-MM-DD (ví dụ: 1971-10-06). |
| `create_date` | `DATE` | Ngày tạo bản ghi khách hàng trong hệ thống CRM. |

---

### 2. **gold.dim_products**
- **Mục đích:** Cung cấp thông tin chi tiết về các sản phẩm, phân loại danh mục, chi phí và trạng thái bảo trì (chỉ giữ lại các sản phẩm đang có hiệu lực).
- **Danh sách cột:**

| Tên Cột (Column Name) | Kiểu Dữ Liệu (Data Type) | Mô Tả (Description) |
| :--- | :--- | :--- |
| `product_key` | `INT` | Khóa thay thế (Surrogate Key) định danh duy nhất mỗi bản ghi sản phẩm trong bảng Dimension. |
| `product_id` | `INT` | Mã số định danh duy nhất của sản phẩm từ CRM. |
| `product_number` | `NVARCHAR(50)` | Mã sản phẩm (`prd_key`) dùng cho quản lý kho và liên kết với Fact Sales. |
| `product_name` | `NVARCHAR(50)` | Tên mô tả đầy đủ của sản phẩm (bao gồm loại, màu sắc, kích cỡ). |
| `category_id` | `NVARCHAR(50)` | Mã danh mục sản phẩm, liên kết với hệ thống phân loại ERP. |
| `category` | `NVARCHAR(50)` | Tên danh mục sản phẩm cấp cao (ví dụ: Bikes, Components, Accessories). |
| `subcategory` | `NVARCHAR(50)` | Phân loại chi tiết hơn trong từng danh mục (ví dụ: Mountain Bikes, Road Frames). |
| `maintenance` | `NVARCHAR(50)` | Cho biết sản phẩm có yêu cầu bảo trì hay không (ví dụ: 'Yes', 'No'). |
| `cost` | `INT` | Giá vốn hoặc chi phí sản xuất cơ bản của sản phẩm. |
| `product_line` | `NVARCHAR(50)` | Dòng sản phẩm tương ứng đã chuẩn hóa (ví dụ: Road, Mountain, Touring, Other Sales). |
| `start_date` | `DATE` | Ngày bắt đầu áp dụng / kinh doanh sản phẩm. |

---

### 3. **gold.fact_sales**
- **Mục đích:** Lưu trữ dữ liệu sự kiện giao dịch bán hàng phục vụ đo lường và phân tích hiệu quả kinh doanh.
- **Danh sách cột:**

| Tên Cột (Column Name) | Kiểu Dữ Liệu (Data Type) | Mô Tả (Description) |
| :--- | :--- | :--- |
| `order_number` | `NVARCHAR(50)` | Mã số đơn hàng duy nhất cho mỗi giao dịch bán hàng (ví dụ: 'SO54496'). |
| `product_key` | `INT` | Khóa ngoại (Surrogate Key) liên kết sang bảng `gold.dim_products`. |
| `customer_key` | `INT` | Khóa ngoại (Surrogate Key) liên kết sang bảng `gold.dim_customers`. |
| `order_date` | `DATE` | Ngày khách hàng đặt đơn hàng. |
| `shipping_date` | `DATE` | Ngày đơn hàng được giao/vận chuyển tới khách hàng. |
| `due_date` | `DATE` | Ngày hạn chót thanh toán đơn hàng. |
| `sales_amount` | `INT` | Tổng giá trị doanh thu của dòng sản phẩm trong đơn hàng (`sls_quantity * sls_price`). |
| `quantity` | `INT` | Số lượng sản phẩm được mua trong dòng đơn hàng. |
| `price` | `INT` | Đơn giá của từng sản phẩm trong dòng đơn hàng. |
