# Lab: การวิเคราะห์ I/O Performance

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`
- **Permissions**: `sysadmin` (เพื่อใช้คำสั่ง `DBCC DROPCLEANBUFFERS`)

## Scenario (สถานการณ์)
ผู้ใช้งานแจ้งว่า "รายงานทำงานช้ามาก" คุณสงสัยว่าระบบ Storage อาจจะเป็นคอขวด (Bottleneck) หรือ Query อาจจะมีการอ่านข้อมูลจาก Disk มากเกินไป (Physical Reads)

## Objectives (วัตถุประสงค์)
1.  ใช้ `SET STATISTICS IO` เพื่อวัดค่า Logical Reads
2.  ใช้ `DBCC DROPCLEANBUFFERS` เพื่อบังคับให้เกิด Physical Reads (ล้าง Cache)
3.  วิเคราะห์ Disk Latency ผ่านทาง DMVs

---

## Exercise 1: การวัดค่า I/O (Logical vs Physical)

### Step 1: วิเคราะห์ Logical Reads (Cold Cache vs Warm Cache)
1.  เปิดไฟล์ `Scripts\01_Workload_IO.sql`
2.  เปิดโหมด "Include Actual Execution Plan" (Ctrl+M)
3.  รัน Script ส่วน **Step 1 (Cold Cache)**:
    *   คำสั่งนี้จะบังคับให้ SQL อ่านข้อมูลจาก Disk จริงๆ (Physical Read)
    *   สังเกตที่แท็บ "Messages" จะเห็นยอด `Physical reads` สูง
4.  รัน Script ส่วน **Step 2 (Warm Cache)**:
    *   คำสั่งนี้จะอ่านข้อมูลจาก Buffer Pool (Memory)
    *   สังเกตว่า `Physical reads` จะกลายเป็น 0 แต่ `Logical reads` ยังคงสูงเท่าเดิม

### Step 2: เปรียบเทียบ Scan vs Seek
1.  รัน Script ส่วน **Step 3 (Index Seek)**
2.  เปรียบเทียบค่า `Logical reads` กับแบบ Scan ก่อนหน้า
    *   **Scan**: Logical Reads สูงมาก (เพราะต้องอ่านทุกหน้า)
    *   **Seek**: Logical Reads ต่ำ (เพราะวิ่งผ่าน B-Tree ไปหาข้อมูลเลย)

---

## Exercise 2: การ Monitor Virtual File Stats

1.  ในขณะที่รัน IO Workload (อาจจะรันวนลูปทิ้งไว้), ให้ตรวจสอบค่า Latency ของไฟล์:
    ```sql
    SELECT 
        DB_NAME(vfs.database_id) AS DBName,
        mf.name AS FileName,
        io_stall_read_ms / NULLIF(num_of_reads, 0) AS AvgReadLatency_ms,
        io_stall_write_ms / NULLIF(num_of_writes, 0) AS AvgWriteLatency_ms
    FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
    JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
    WHERE vfs.database_id = DB_ID('AdventureWorks2022')
    ORDER BY AvgReadLatency_ms DESC;
    ```
2.  **เกณฑ์วัดผล (Benchmark)**:
    *   < 5ms: ดีมาก (Excellent)
    *   10-20ms: พอใช้ (Acceptable)
    *   > 20ms: เริ่มมีปัญหาคอขวด (Potential Bottleneck)

---

## Exercise 3: Advanced - การวิเคราะห์ Latency ระดับ Drive
*แบบฝึกหัดขั้นสูงนี้จะใช้ `02_Drive_Latency.sql` เพื่อดูภาพรวมสุขภาพของ Storage Subsystem*

### Concept (แนวคิด)
ในขณะที่ `sys.dm_io_virtual_file_stats` บอกค่า Latency รายไฟล์ แต่บางครั้งคอขวดอาจจะอยู่ที่ตัว **Physical Drive** เอง (ซึ่งแชร์กันหลายไฟล์ หรือหลาย Database)

### Steps (ขั้นตอน)
1.  เปิดและรัน: `Scripts\02_Drive_Latency.sql`
2.  วิเคราะห์คอลัมน์ต่างๆ:
    *   **Read/Write Latency**: แยกค่า Latency ของการอ่านและเขียน เพื่อดูว่าช้าที่ฝั่งไหน
    *   **Overall Latency**: ค่าเฉลี่ยรวม
    *   **Avg Bytes/Transfer**: บอกขนาดของ I/O Size โดยเฉลี่ย
        *   ถ้าค่าสูง (เช่น 64KB+) มักเกิดจากกิจกรรมอย่าง Table Scan หรือ Backup
        *   ถ้าค่าต่ำ (8KB) มักเกิดจากกิจกรรม OLTP (Index Seek, Key Lookup)
