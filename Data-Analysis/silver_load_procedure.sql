DELIMITER $$

CREATE PROCEDURE load_silver()
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    SET batch_start_time = NOW();

    -- CRM Customer Info
    SET start_time = NOW();
    TRUNCATE TABLE silver_crm_cust_info;
    INSERT INTO silver_crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze_crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
    SET end_time = NOW();

    -- CRM Product Info
    SET start_time = NOW();
    TRUNCATE TABLE silver_crm_prd_info;
    INSERT INTO silver_crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
        SUBSTRING(prd_key, 7),
        prd_nm,
        IFNULL(prd_cost, 0),
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        CAST(prd_start_dt AS DATE),
        NULL
    FROM bronze_crm_prd_info;
    SET end_time = NOW();

    -- CRM Sales Details
    SET start_time = NOW();
    TRUNCATE TABLE silver_crm_sales_details;
    INSERT INTO silver_crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN LENGTH(sls_order_dt) = 8 AND sls_order_dt NOT IN (0, '0') THEN STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
            ELSE NULL
        END,
        CASE
            WHEN LENGTH(sls_ship_dt) = 8 AND sls_ship_dt NOT IN (0, '0') THEN STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
            ELSE NULL
        END,
        CASE
            WHEN LENGTH(sls_due_dt) = 8 AND sls_due_dt NOT IN (0, '0') THEN STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
            ELSE NULL
        END,
        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze_crm_sales_details;
    SET end_time = NOW();

    -- ERP Customer
    SET start_time = NOW();
    TRUNCATE TABLE silver_erp_cust_az12;
    INSERT INTO silver_erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END,
        CASE
            WHEN bdate > NOW() THEN NULL
            ELSE bdate
        END,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END
    FROM bronze_erp_cust_az12;
    SET end_time = NOW();

    -- ERP Location
    SET start_time = NOW();
    TRUNCATE TABLE silver_erp_loc_a101;
    INSERT INTO silver_erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', ''),
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze_erp_loc_a101;
    SET end_time = NOW();

    -- ERP Product Category
    SET start_time = NOW();
    TRUNCATE TABLE silver_erp_px_cat_g1v2;
    INSERT INTO silver_erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
    FROM bronze_erp_px_cat_g1v2;
    SET end_time = NOW();

    SET batch_end_time = NOW();
END $$

DELIMITER ;


CALL load_silver();
