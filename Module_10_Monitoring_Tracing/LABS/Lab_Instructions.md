# Lab: การ Monitoring และการทำ Baseline

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
คุณต้องการสร้าง **Performance Baseline** (ค่ามาตรฐานของระบบ) โดยการจำลอง Workload ผสมๆ กัน แล้วเก็บค่า Key Metrics ผ่านทาง DMVs

## Objectives (วัตถุประสงค์)
1.  รัน "Noise Generator" script เพื่อสร้าง Activity จำลอง
2.  เก็บข้อมูลจาก DMVs สำคัญ (`dm_os_wait_stats`, `dm_exec_requests`, `dm_io_virtual_file_stats`)
3.  วิเคราะห์ข้อมูลเพื่อเข้าใจสถานะ "ปกติ" ของระบบ

---

## Exercise 1: Generating Baseline Data

### Step 1: เริ่ม Workload
1.  เปิดไฟล์ `LABS\Scripts\01_Workload_Noise.sql`
2.  รัน Script นี้ใน **หลายๆ Query Window** (เช่น 3-5 หน้าต่าง) เพื่อให้เกิด Load พร้อมๆ กัน
    *   Script จะทำการ Read, Write และ Wait สลับกันไปมั่วๆ

### Step 2: Monitor Real-time
1.  เปิดไฟล์ `LABS\Scripts\02_Monitor_Queries.sql`
2.  รัน Query เพื่อดู:
    *   **Top Wait Types**: อะไรคือสิ่งที่ระบบรอมากที่สุด?
    *   **Active Requests**: Thread เหล่านั้นกำลังทำอะไรอยู่?
    *   **File I/O Latency**: Disk ทำงานทันหรือไม่?

### Step 3: แปลผล (Interpret Findings)
*   ถ้าเจอ `SOS_SCHEDULER_YIELD` เยอะ -> CPU ทำงานหนัก (Math loops)
*   ถ้าเจอ `PAGEIOLATCH_SH` เยอะ -> Disk ทำงานหนัก (Random reads)
*   ถ้าเจอ `WRITELOG` เยอะ -> Transaction Log เขียนไม่ทัน (Updates/Inserts)

---

## Exercise 2: PerfMon (Optional)
1.  เปิดโปรแกรม "Performance Monitor" ใน Windows
2.  ลอง Add Counters:
    *   `SQLServer:Buffer Manager > Page life expectancy` (ควรสูงและนิ่ง)
    *   `SQLServer:General Statistics > User Connections`
3.  สังเกตการเปลี่ยนแปลงเมื่อคุณ Start/Stop ตัว Workload
