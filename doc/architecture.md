# 📐 Kiến trúc Hệ thống & Mô hình Dữ liệu (Data Architecture & Models)

Tài liệu này tổng hợp toàn bộ các sơ đồ kiến trúc, dòng chảy dữ liệu (Data Lineage), mô hình tích hợp dữ liệu nguồn và mô hình hình sao (Star Schema) của hệ thống **SQL Data Warehouse**.

---

## 📌 Mục lục
1. [Kiến trúc tổng quan (Medallion Architecture)](#1-kiến-trúc-tổng-quan-medallion-architecture)
2. [Luồng dữ liệu & Nguồn gốc (Data Flow / Data Lineage)](#2-luồng-dữ-liệu--nguồn-gốc-data-flow--data-lineage)
3. [Mô hình tích hợp nguồn dữ liệu (Source Integration Model)](#3-mô-hình-tích-hợp-nguồn-dữ-liệu-source-integration-model)
4. [Mô hình hình sao tầng Gold (Star Schema / Dimensional Model)](#4-mô-hình-hình-sao-tầng-gold-star-schema--dimensional-model)

---

## 1. Kiến trúc tổng quan (Medallion Architecture)

Hệ thống Data Warehouse được thiết kế theo mô hình 3 tầng chuẩn (Bronze ➔ Silver ➔ Gold):

```mermaid
flowchart LR
    subgraph Bronze["🥉 Bronze Layer"]
        direction TB
        B_SP["⚡ Stored Procedure<br/><code>bronze.load_bronze</code>"]
        B_DB[("📦 Raw Data")]
        B_INFO["<b>Object Type:</b> Tables<br/><b>Load:</b> Batch Processing, Full Load, Truncate & Insert<br/><b>Transformations:</b> None (as-is)<br/><b>Data Model:</b> None (as-is)"]
        B_SP --> B_DB
        B_DB --> B_INFO
    end

    subgraph Silver["🥈 Silver Layer"]
        direction TB
        S_SP["⚡ Stored Procedure<br/><code>silver.load_silver</code>"]
        S_DB[("✨ Cleaned & Standardized Data")]
        S_INFO["<b>Object Type:</b> Tables<br/><b>Load:</b> Batch Processing, Full Load, Truncate & Insert<br/><b>Transformations:</b> Data Cleansing, Data Standardization, Data Normalization, Derived Columns, Data Enrichment<br/><b>Data Model:</b> None (as-is)"]
        S_SP --> S_DB
        S_DB --> S_INFO
    end

    subgraph Gold["🥇 Gold Layer"]
        direction TB
        G_DB[("🏆 Business-Ready Data")]
        G_INFO["<b>Object Type:</b> Views<br/><b>Load:</b> No Load (Virtual Layer)<br/><b>Transformations:</b> Data Integrations, Aggregations, Business Logics<br/><b>Data Model:</b> Star Schema, Flat Table, Aggregated Table"]
        G_DB --> G_INFO
    end

    Bronze ==>|ETL / Data Cleansing| Silver
    Silver ==>|Data Modeling & Analytics Views| Gold
```

### 📋 So sánh đặc điểm các tầng (Layer Comparison)

| Tiêu chí | 🥉 Bronze Layer | 🥈 Silver Layer | 🥇 Gold Layer |
| :--- | :--- | :--- | :--- |
| **Trạng thái dữ liệu** | Dữ liệu thô (Raw Data) | Dữ liệu sạch, chuẩn hóa (Cleaned, Standardized Data) | Dữ liệu sẵn sàng cho nghiệp vụ (Business-Ready Data) |
| **Loại đối tượng (Object Type)** | `Tables` | `Tables` | `Views` |
| **Cơ chế nạp (Load)** | • Batch Processing<br/>• Full Load<br/>• Truncate & Insert | • Batch Processing<br/>• Full Load<br/>• Truncate & Insert | • **No Load** (Truy vấn trực tiếp qua Views) |
| **Chuyển đổi (Transformations)** | **No Transformations** | • Data Cleansing<br/>• Data Standardization<br/>• Data Normalization<br/>• Derived Columns<br/>• Data Enrichment | • Data Integrations<br/>• Aggregations<br/>• Business Logics |
| **Mô hình hóa (Data Model)** | None (as-is) | None (as-is) | • Star Schema (Facts & Dimensions)<br/>• Flat Table<br/>• Aggregated Table |

---

## 2. Luồng dữ liệu & Nguồn gốc (Data Flow / Data Lineage)

Sơ đồ thể hiện chi tiết nguồn gốc và dòng chảy dữ liệu (Data Lineage) từ các tập tin nguồn qua từng tầng, được phân nhóm **CRM hoàn chỉnh trước rồi đến ERP**:

```mermaid
flowchart LR
    subgraph Sources["📁 Sources"]
        direction TB
        subgraph CRM_SRC["🏢 CRM (Source Files)"]
            direction TB
            CRM_cust["cust_info.csv"]
            CRM_prd["prd_info.csv"]
            CRM_sales["sales_details.csv"]
        end
        subgraph ERP_SRC["🏭 ERP (Source Files)"]
            direction TB
            ERP_cust["CUST_AZ12.csv"]
            ERP_loc["LOC_A101.csv"]
            ERP_cat["PX_CAT_G1V2.csv"]
        end
    end

    subgraph Bronze["🥉 Bronze Layer"]
        direction TB
        subgraph B_CRM["🏢 CRM Tables"]
            direction TB
            B_cust["bronze.crm_cust_info"]
            B_prd["bronze.crm_prd_info"]
            B_sales["bronze.crm_sales_details"]
        end
        subgraph B_ERP["🏭 ERP Tables"]
            direction TB
            B_az12["bronze.erp_cust_az12"]
            B_loc["bronze.erp_loc_a101"]
            B_cat["bronze.erp_px_cat_g1v2"]
        end
    end

    subgraph Silver["🥈 Silver Layer"]
        direction TB
        subgraph S_CRM["🏢 CRM Tables"]
            direction TB
            S_cust["silver.crm_cust_info"]
            S_prd["silver.crm_prd_info"]
            S_sales["silver.crm_sales_details"]
        end
        subgraph S_ERP["🏭 ERP Tables"]
            direction TB
            S_az12["silver.erp_cust_az12"]
            S_loc["silver.erp_loc_a101"]
            S_cat["silver.erp_px_cat_g1v2"]
        end
    end

    subgraph Gold["🥇 Gold Layer"]
        direction TB
        G_dim_cust["dim_customers<br/><i>(Dimension)</i>"]
        G_dim_prd["dim_products<br/><i>(Dimension)</i>"]
        G_fact["fact_sales<br/><i>(Fact)</i>"]
    end

    %% Sources -> Bronze (CRM)
    CRM_cust --> B_cust
    CRM_prd --> B_prd
    CRM_sales --> B_sales

    %% Sources -> Bronze (ERP)
    ERP_cust --> B_az12
    ERP_loc --> B_loc
    ERP_cat --> B_cat

    %% Bronze -> Silver (CRM)
    B_cust --> S_cust
    B_prd --> S_prd
    B_sales --> S_sales

    %% Bronze -> Silver (ERP)
    B_az12 --> S_az12
    B_loc --> S_loc
    B_cat --> S_cat

    %% Silver -> Gold (Integration)
    S_cust --> G_dim_cust
    S_az12 --> G_dim_cust
    S_loc --> G_dim_cust

    S_prd --> G_dim_prd
    S_cat --> G_dim_prd

    S_sales --> G_fact

    %% Styling
    classDef bronzeStyle fill:#fff3e0,stroke:#f57c00,stroke-width:1.5px,color:#e65100
    classDef silverStyle fill:#eceff1,stroke:#78909c,stroke-width:1.5px,color:#263238
    classDef goldStyle fill:#fffde7,stroke:#fbc02d,stroke-width:1.5px,color:#f57f17

    class B_cust,B_prd,B_sales,B_az12,B_loc,B_cat bronzeStyle
    class S_cust,S_prd,S_sales,S_az12,S_loc,S_cat silverStyle
    class G_dim_cust,G_dim_prd,G_fact goldStyle
```

### 🔄 Chi tiết luồng tích hợp tầng Gold:
- **`gold.dim_customers`**: Tích hợp từ `silver.crm_cust_info` (CRM) + `silver.erp_cust_az12` (ERP) + `silver.erp_loc_a101` (ERP).
- **`gold.dim_products`**: Tích hợp từ `silver.crm_prd_info` (CRM) + `silver.erp_px_cat_g1v2` (ERP).
- **`gold.fact_sales`**: Nạp từ `silver.crm_sales_details` (CRM).

---

## 3. Mô hình tích hợp nguồn dữ liệu (Source Integration Model)

Sơ đồ thể hiện mối quan hệ giữa các bảng nguồn từ 2 hệ thống **CRM** và **ERP** theo các miền nghiệp vụ (**Domain: CUSTOMER, PRODUCT, SALES**):

```mermaid
flowchart LR
    subgraph CRM["🏢 CRM (Customer Relationship Management)"]
        direction LR
        sales["<b>crm_sales_details</b><br/><i>Transactional Records about Sales & Orders</i><br/>🔑 <code>prd_key</code><br/>🔑 <code>cst_id</code><br/>━━━━━━━━━━━━━<br/><b>🟣 SALES</b>"]
        
        subgraph CRM_ENTITIES[" "]
            direction TB
            prd["<b>crm_prd_info</b><br/><i>Current & History Product Information</i><br/>🔑 <code>prd_key</code><br/>━━━━━━━━━━━━━<br/><b>🔴 PRODUCT</b>"]
            cust["<b>crm_cust_info</b><br/><i>Customer Information</i><br/>🔑 <code>cst_id</code><br/>🔑 <code>cst_key</code><br/>━━━━━━━━━━━━━<br/><b>🟢 CUSTOMER</b>"]
        end

        sales -->|prd_key| prd
        sales -->|cst_id| cust
    end

    subgraph ERP["🏭 ERP (Enterprise Resource Planning)"]
        direction TB
        cat["<b>erp_px_cat_g1v2</b><br/><i>Product Categories</i><br/>🔑 <code>id</code><br/>━━━━━━━━━━━━━<br/><b>🔴 PRODUCT</b>"]
        extra["<b>erp_cust_az12</b><br/><i>Extra Customer Information (Birthdate)</i><br/>🔑 <code>cid</code><br/>━━━━━━━━━━━━━<br/><b>🟢 CUSTOMER</b>"]
        loc["<b>erp_loc_a101</b><br/><i>Location of Customers (Country)</i><br/>🔑 <code>cid</code><br/>━━━━━━━━━━━━━<br/><b>🟢 CUSTOMER</b>"]
    end

    prd -->|id| cat
    cust -->|cid| extra
    cust -->|cid| loc

    classDef salesDomain fill:#f3e5f5,stroke:#8e24aa,stroke-width:1.5px,color:#4a148c
    classDef productDomain fill:#ffebee,stroke:#e53935,stroke-width:1.5px,color:#b71c1c
    classDef customerDomain fill:#e8f5e9,stroke:#43a047,stroke-width:1.5px,color:#1b5e20
    classDef crmGroup fill:#f0f7ff,stroke:#0288d1,stroke-width:1.5px,stroke-dasharray: 5 5
    classDef erpGroup fill:#fffde7,stroke:#fbc02d,stroke-width:1.5px,stroke-dasharray: 5 5

    class CRM crmGroup
    class ERP erpGroup
    class sales salesDomain
    class prd,cat productDomain
    class cust,extra,loc customerDomain
    style CRM_ENTITIES fill:none,stroke:none
```

### 🏷️ Phân loại theo Miền nghiệp vụ (Business Domains):
- 🟢 **CUSTOMER (Khách hàng)**:
  - `crm_cust_info` (CRM - Thông tin định danh, tên, hôn nhân, giới tính)
  - `erp_cust_az12` (ERP - Ngày sinh `bdate`, giới tính `gen`) liên kết qua `cid = cst_key`
  - `erp_loc_a101` (ERP - Vị trí quốc gia `cntry`) liên kết qua `cid = cst_key`
- 🔴 **PRODUCT (Sản phẩm)**:
  - `crm_prd_info` (CRM - Thông tin sản phẩm, giá vốn, dòng sản phẩm, ngày hiệu lực)
  - `erp_px_cat_g1v2` (ERP - Danh mục `cat`, tiểu mục `subcat`, bảo trì `maintenance`) liên kết qua `id = cat_id`
- 🟣 **SALES (Bán hàng & Đơn hàng)**:
  - `crm_sales_details` (CRM - Chi tiết đơn hàng, số lượng, doanh thu) liên kết tới Sản phẩm qua `prd_key` và Khách hàng qua `cst_id`

---

## 4. Mô hình hình sao tầng Gold (Star Schema / Dimensional Model)

Sơ đồ thể hiện thiết kế Dimensional Model tầng Gold gồm bảng Fact trung tâm liên kết với các bảng Dimension qua Surrogate Keys:

```mermaid
erDiagram
    gold_dim_customers ||--o{ gold_fact_sales : "FK2: customer_key"
    gold_dim_products ||--o{ gold_fact_sales : "FK1: product_key"

    gold_dim_customers {
        int customer_key PK "Surrogate Key"
        int customer_id "Customer ID"
        nvarchar customer_number "Customer Key"
        nvarchar first_name "First Name"
        nvarchar last_name "Last Name"
        nvarchar country "Country"
        nvarchar marital_status "Marital Status"
        nvarchar gender "Gender"
        date birthdate "Birthdate"
        date create_date "Create Date"
    }

    gold_fact_sales {
        nvarchar order_number "Order Number"
        int product_key FK "FK -> dim_products"
        int customer_key FK "FK -> dim_customers"
        date order_date "Order Date"
        date shipping_date "Shipping Date"
        date due_date "Due Date"
        numeric sales_amount "Sales Calculation (Qty * Price)"
        int quantity "Quantity"
        numeric price "Price"
    }

    gold_dim_products {
        int product_key PK "Surrogate Key"
        int product_id "Product ID"
        nvarchar product_number "Product Number"
        nvarchar product_name "Product Name"
        int category_id "Category ID"
        nvarchar category "Category"
        nvarchar subcategory "Subcategory"
        nvarchar maintenance "Maintenance"
        numeric cost "Cost"
        nvarchar product_line "Product Line"
        date start_date "Start Date"
    }
```

### 📋 Chi tiết các quan hệ (Relationships):
- **`gold.dim_customers` ➔ `gold.fact_sales`**: Quan hệ 1 - N qua `customer_key`. Mỗi khách hàng có thể có nhiều giao dịch bán hàng.
- **`gold.dim_products` ➔ `gold.fact_sales`**: Quan hệ 1 - N qua `product_key`. Mỗi sản phẩm có thể xuất hiện trong nhiều dòng đơn hàng.
