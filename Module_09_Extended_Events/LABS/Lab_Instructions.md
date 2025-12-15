# Lab: Extended Events (XEvents)

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`
- **Tools**: SSMS XEvent Wizard หรือ T-SQL

## Scenario (สถานการณ์)
คุณต้องการจับภาพเหตุการณ์ (Events) เฉพาะเจาะจง เช่น Deadlocks หรือ Query ที่ทำงานช้า โดยให้มีผลกระทบต่อเครื่องน้อยที่สุด (Minimal Overhead)
หัวหน้าสั่งห้ามใช้ SQL Profiler เด็ดขาด! คุณจึงต้องใช้ **XEvents**

## Objectives (วัตถุประสงค์)
1.  สร้าง XEvent Session เพื่อดักจับ Deadlock
2.  ใช้ `ring_buffer` target เพื่อดูข้อมูลแบบทันที
3.  แสดงผล Visualization ใน SSMS

---

## Exercise 1: การดักจับ Deadlocks

### Step 1: สร้าง Session
1.  เปิดไฟล์ `LABS\Scripts\01_Create_XE_Session.sql`
2.  รัน Script เพื่อสร้าง Session ชื่อ `XE_Deadlock_Monitor`
3.  Start Session (ถ้ายังไม่ได้ Start)

### Step 2: สร้าง Workload
1.  รัน Script **Deadlock Lab** จาก Module 5 อีกครั้ง (`Module_05_Concurrency\LABS\Scripts\02_Deadlock...`)
2.  ทำให้เกิด Deadlock (Error 1205) จริงๆ

### Step 3: วิเคราะห์ข้อมูล
1.  เปิดไฟล์ `LABS\Scripts\03_Read_XE_Data.sql`
2.  รัน Query เพื่อดึง XML จาก Ring Buffer
3.  คลิกที่ Link XML เพื่อดู Deadlock Graph (จะเห็นภาพชัดเจนว่าใครฆ่าใคร)

---

## Exercise 2: Live Data Watcher
1.  ใน SSMS Object Explorer ไปที่ Management -> Extended Events -> Sessions
2.  คลิกขวาที่ `XE_Deadlock_Monitor` เลือก **Watch Live Data**
3.  ลองทำให้เกิด Deadlock อีกรอบ
4.  คุณจะเห็น Event เด้งขึ้นมาบนหน้าจอแบบ Real-time!

---

## Exercise 3: Advanced - Blocking & Deadlock รวมในที่เดียว
*แบบฝึกหัดขั้นสูงนี้จะใช้ `04_XE_Blocking_Deadlock.sql` เพื่อ Monitor ทุกลมหายใจของการ Lock*

### Concept (แนวคิด)
นอกจากการดู Deadlock แล้ว เรามักอยากรู้เรื่อง Blocking ที่นานเกินกำหนดด้วย (blocked_process_report)

### Steps (ขั้นตอน)
1.  เปิดและรัน: `LABS\Scripts\04_XE_Blocking_Deadlock.sql`
2.  Script นี้จะสร้าง Session ที่จับทั้ง:
    *   `xml_deadlock_report` (เมื่อเกิด Deadlock)
    *   `blocked_process_report` (เมื่อมีการ Block นานกว่า Threshold ที่ตั้งไว้ใน sp_configure)
3.  นี่คือ Script มาตรฐานที่ควรมีติดทุก Server!
