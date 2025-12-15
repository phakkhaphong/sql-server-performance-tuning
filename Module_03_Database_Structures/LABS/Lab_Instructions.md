# Lab: โครงสร้าง Database และการเกิด Segmentation

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
คุณกำลังสอบสวนว่าทำไมตาราง `PersonLog_Bad` ถึงมีประสิทธิภาพการ Insert ที่แย่มาก และทำให้ Transaction Log บวมผิดปกติ
คุณสงสัยเรื่อง **Fragmentation** ที่เกิดจาก **Page Splits** เนื่องจากมีการใช้ Clustered Key ที่ไม่เหมาะสม (Random GUID)

## Objectives (วัตถุประสงค์)
1.  สาธิตผลกระทบของการใช้ Random GUID เป็น Clustered Key
2.  สังเกตปรากฏการณ์ Page Splits และ Fragmentation
3.  เปรียบเทียบประสิทธิภาพกับ Sequential Key (Identity/Int)

---

## Exercise 1: Bad Index Design (Random GUID)

### Step 1: สร้างตาราง
1.  เปิดไฟล์ `LABS\Scripts\01_Bad_vs_Good_Structure.sql`
2.  รันส่วน "Setup Tables"
    *   `BadKeyTable`: ใช้ `NEWID()` เป็น Primary Key (Clustered) ซึ่งจะสุ่มค่าตลอดเวลา
    *   `GoodKeyTable`: ใช้ `INT IDENTITY` เป็น Primary Key (Clustered) ซึ่งจะเรียงลำดับสวยงาม

### Step 2: สร้าง Workload (Inserts)
1.  รันส่วน "Workload"
    *   Script จะทำการ Insert ข้อมูล 10,000 แถวลงในทั้งสองตาราง
    *   สังเกตเวลาที่ใช้ (`Time Taken`) ในแถบ Messages

### Step 3: วิเคราะห์ Fragmentation
1.  รันส่วน "Analysis":
    ```sql
    SELECT 
        OBJECT_NAME(object_id) AS TableName, 
        index_type_desc, 
        avg_fragmentation_in_percent, 
        page_count,
        fragment_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED')
    WHERE OBJECT_NAME(object_id) IN ('BadKeyTable', 'GoodKeyTable');
    ```
2.  **ผลลัพธ์**:
    *   `BadKeyTable`: Fragmentation น่าจะสูงเกือบ 99% (เกิดจาก Random inserts ทำให้หน้า (Page) แตกและกระจัดกระจาย)
    *   `GoodKeyTable`: Fragmentation น่าจะต่ำมาก < 1% (เพราะเป็นการต่อท้ายไฟล์ไปเรื่อยๆ)

### Step 4: Page Splits (ผลกระทบต่อ Transaction Log)
1.  ดูที่ `fn_dblog` (Advanced) หรือทำความเข้าใจว่า ทุกครั้งที่เกิด Page Split จะมีการเขียน Log เพิ่มเติมจำนวนมาก ทำให้ Backup ใหญ่ขึ้นและ Restore ช้าลง

---

## Exercise 2: Ledger Tables (Optional - SQL 2022)
เนื่องจากแล็บนี้ไม่มี Script แยกให้ในโฟลเดอร์ `LABS\Scripts` ให้ใช้เป็นการอ่านและทดลองจากเอกสาร Microsoft แทน:
1. ศึกษาแนวคิด Ledger จากเอกสาร Microsoft Learn (SQL Server Ledger Tables)
2. ลองออกแบบตารางที่ต้องการป้องกันการแก้ไขย้อนหลัง และพิจารณาว่าจะใช้ Ledger อย่างไรในระบบจริงของคุณ

---

## Exercise 3: Advanced - การวิเคราะห์ Page Splits ด้วย XEvents
*แบบฝึกหัดขั้นสูงนี้จะใช้ Script Page Split Tracking จาก Module 09 เพื่อจับตาดู Page Split แบบ Real-time*

### Concept (แนวคิด)
การดู Page Split จาก Transaction Log เป็นเรื่องยุ่งยาก XEvents มี Event ชื่อ `page_split` ที่เบาและใช้ง่ายกว่า

### Steps (ขั้นตอน)
1.  เปิดและรัน `Module_09_Extended_Events\LABS\Scripts\05_Page_Splits_Tracking.sql`
    *   Script นี้จะสร้าง XEvent Session และเริ่มจับข้อมูลทันที
2.  ลองรัน Workload Insert (Random GUID) อีกครั้ง
3.  ดูข้อมูลใน Ring Buffer จาก Query หรือ Watch Live Data
4.  **ผลลัพธ์**: คุณจะเห็นรายการ Page Split วิ่งขึ้นมา ซึ่งยืนยันสมมติฐานเรื่อง "Bad Key" ได้ทันที
