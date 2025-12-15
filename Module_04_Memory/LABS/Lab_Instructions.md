# Lab: การจัดการ Memory และ Memory Grants

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
Report query ตัวหนึ่งทำงานช้าและมี "Warning" ขึ้นใน Execution Plan
คุณสงสัยเรื่อง **Memory Spills** (Sort Warning / Hash Warning) เพราะ Query มีการ Sort ข้อมูล Text ขนาดใหญ่

## Objectives (วัตถุประสงค์)
1.  จำลองสถานการณ์ Memory Spill (Sort Warning)
2.  สังเกต Event ใน Execution Plan
3.  สาธิตฟีเจอร์ **Memory Grant Feedback** (SQL 2017/2019+) ที่ช่วยแก้ปัญหานี้ให้เองโดยอัตโนมัติ

---

## Exercise 1: Memory Grant Spill & Feedback

### Step 1: Baseline (บังคับให้ Spill)
1.  เปิดไฟล์ `LABS\Scripts\01_Memory_Spill.sql`
2.  รัน Query **Step 1**
    *   Query จะทำการ `ORDER BY` คอลัมน์ขนาดใหญ่ (จำลองด้วย `CAST` เป็น `NVARCHAR(MAX)`)
    *   สังเกตไอคอน "Warning" สีเหลืองบน `Sort` Operator ใน Execution Plan
    *   เอาเมาส์ชี้ดู Tooltip: "Operator used tempdb to spill data..." (แปลว่าแรมไม่พอ เลยต้องเขียนลง Disk แทน)

### Step 2: Automatic Tuning (Memory Grant Feedback)
1.  รัน Query เดิมซ้ำอีกรอบ (**Step 2**)
2.  SQL Server (เวอร์ชัน 2017+) จะจำได้ว่ารอบที่แล้วแรมไม่พอ และจะ **เพิ่ม** Memory Grant ให้ในรอบนี้
3.  สังเกตว่า Warning หายไปแล้ว
4.  เช็ค Properties ของ Root Node (SELECT): `IsMemoryGrantFeedbackAdjusted: Yes`

### Step 3: Bad Parameter Sniffing (Over-grant)
*   ในทางกลับกัน ถ้าเราขอแรมเผื่อไว้เยอะๆ (Over-grant) แล้วรันข้อมูลน้อยๆ เราก็จะเปลืองแรมโดยใช่เหตุ (ซึ่ง SQL รุ่นใหม่ๆ ก็พยายามแก้ตรงนี้ให้เช่นกัน)

---

## Exercise 2: การ Monitor Memory Clerks
1.  รัน Query เพื่อดูว่าใครใช้แรมเยอะสุด:
    ```sql
    SELECT TOP 10 type, pages_kb/1024 AS MB
    FROM sys.dm_os_memory_clerks
    ORDER BY pages_kb DESC;
    ```
2.  รู้จักขาใหญ่ประจำเครื่อง:
    *   `MEMORYCLERK_SQLBUFFERPOOL`: คือ Buffer Pool (Cache ข้อมูลปกติ)
    *   `MEMORYCLERK_SQLQUERYEXEC`: แรมที่ใช้สำหรับ Sort/Hash (ถ้าเยอะแปลว่ามี Query หนักๆ เยอะ)
