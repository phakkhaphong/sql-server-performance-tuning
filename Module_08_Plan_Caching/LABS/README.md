# Lab: Plan Caching และ Parameter Sniffing

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
Stored Procedure ตัวหนึ่งทำงานเร็วมากสำหรับ User บางคน แต่ช้าต้วมเตี้ยมสำหรับ User อื่น
คุณสงสัยว่าเป็น **Parameter Sniffing** ซึ่งเกิดจากการที่ SQL Server สร้าง Plan สำหรับลูกค้า "รายย่อย" (Small data) แล้วนำมาใช้ซ้ำกับลูกค้า "รายใหญ่" (Big data) หรือในทางกลับกัน

## Objectives (วัตถุประสงค์)
1.  จำลองพฤติกรรม Parameter Sniffing
2.  สังเกตความต่างของ "Parameter Compiled Value" vs "Parameter Runtime Value" ใน Plan
3.  แก้ไขปัญหาโดยใช้ `OPTION (RECOMPILE)` หรือ `OPTIMIZE FOR`

---

## Exercise 1: Parameter Sniffing

### Step 1: สร้างปัญหา (Stored Proc)
1.  เปิดไฟล์ `Scripts\01_Parameter_Sniffing.sql`
2.  รัน **Step 1** เพื่อสร้าง Stored Procedure ชื่อ `GetOrdersByLocation`
    *   SP นี้ดึงข้อมูล Order ตาม `TerritoryID`
    *   *Note*: ข้อมูลมีความเบ้ (Data Skew) บาง Territory มี Order น้อย บางที่ก็มีเป็นล้าน

### Step 2: แผนที่ดี (Seek)
1.  รัน **Step 2** (ส่งค่า Territory ที่มีข้อมู่น้อย)
    *   Optimizer เลือก `Index Seek` + `Key Lookup` ซึ่งมีประสิทธิภาพดีมากสำหรับ rows น้อยๆ

### Step 3: แผนที่แย่ (Sniffing)
1.  รัน **Step 3** (ส่งค่า Territory ที่มีข้อมูลเยอะ) **โดยไม่ต้อง Compile ใหม่** (ใช้ Plan เดิมจาก Step 2)
    *   SQL Server จะนำ "Seek Plan" กลับมาใช้ซ้ำ
    *   เนื่องจากต้องดึงข้อมูลหลายพัน rows การทำ Lookup หลายพันครั้ง (Random I/O) จึงช้ากว่าการทำ Scan (Sequential I/O) มาก
    *   **อาการ**: `Logical Reads` พุ่งสูงผิดปกติ

### Step 4: วิธีแก้ไข
1.  รัน **Step 4** โดยเติม `OPTION (RECOMPILE)`
    *   SQL Server จะสร้าง Plan ใหม่ให้ทุกครั้งที่รัน ซึ่งรอบนี้จะได้ `Cluster Scan` ที่เหมาะสมกับข้อมูลเยอะๆ

---

---

## Exercise 2: Monitoring & Fixing Regressions (Microsoft Learn Scenario)

ในแบบฝึกหัดนี้ คุณจะจำลองสถานการณ์ "Performance Regression" (ประสิทธิภาพแย่ลงหลังการเปลี่ยนแปลง) และใช้ Query Store เพื่อวิเคราะห์และแก้ไข

### Step 1: เตรียม Environment
1.  เปิดไฟล์ `Module_08_Plan_Caching\Scripts\02_Query_Store_Regression_Lab.sql`
2.  รัน **Section 1-3** เพื่อสร้าง Good Plan (Index Seek)
    *   รัน Query 20 รอบเพื่อสร้างประวัติการทำงานที่ดี
3.  รัน **Section 4** เพื่อจำลอง Regression (Drop Index -> Force Scan)
    *   รัน Query อีก 20 รอบเพื่อสร้างประวัติการทำงานที่แย่

### Step 2: วิเคราะห์ด้วย SSMS Reports
1.  ใน **Object Explorer** ไปที่ Database `AdventureWorks2022` > **Query Store**
2.  เปิดรายงาน **Top Resource Consuming Queries**
    *   คุณจะเห็น Query `usp_GetTransactionHistory` อยู่ในอันดับต้นๆ
    *   สังเกตว่ามี **2 Plans** (วงกลม 2 วงในกราฟขวา):
        *   Plan ID น้อย (เก่า): Duration ต่ำ (Good Plan)
        *   Plan ID มาก (ใหม่): Duration สูง (Regressed Plan)
3.  เปิดรายงาน **Regressed Queries**
    *   รายงานนี้จะกรองเฉพาะ Query ที่ประสิทธิภาพ "แย่ลง" อย่างชัดเจนในช่วงเวลาที่เลือก
    *   ช่วยให้ DBA โฟกัสปัญหาได้ตรงจุดกว่าการดู Top Resource ทั่วไป

### Step 3: การตัดสินใจ (Decision Making)
*   ในสถานการณ์จริงที่ Plan เก่ายัง valid (เช่น Parameter Sniffing) คุณสามารถปุ่ม **Force Plan** เพื่อบังคับใช้ Plan เก่าได้เลย
*   ในแล็บนี้ เรา Drop Index ไป ทำให้ Plan เก่าใช้งานไม่ได้ (Invalid)
*   **Solution**: รัน **Section 5** ใน Script เพื่อสร้าง Index คืน (Performance จะกลับมาดีเหมือนเดิม)

---

## Exercise 3: Query Store (Forcing Plan) - Optional Practice
1.  ใช้รายงาน **Top Resource Consuming Queries** เพื่อดูประวัติ
2.  ลองกด **Force Plan** (เลือก Plan ที่คิดว่าดี)
3.  สังเกตไอคอน "ติ๊กถูก" ที่หน้า Plan ID แสดงว่า Plan Forcing ทำงานแล้ว
4.  หากต้องการยกเลิก ให้กด **Unforce Plan**

---

## Exercise 3: Advanced - การดึง Plan สดจาก Memory (แนวคิด)
ในแบบฝึกหัดขั้นสูงนี้ ให้ใช้ DMV และ SSMS โดยไม่อ้างถึง Script เฉพาะไฟล์

### Concept (แนวคิด)
บางครั้งเราไม่สามารถรัน `SET STATISTICS XML ON` ได้เพราะ Query มันรันค้างอยู่ (และนานมาก) เราต้องการเห็น Plan ของมัน **เดี๋ยวนี้**

### Steps (ขั้นตอน)
1.  จำลอง Long-running query ในอีกหน้าต่างหนึ่ง (เช่นใช้ `WAITFOR DELAY`)
2.  ในหน้าต่างใหม่ รัน DMV เช่น `sys.dm_exec_requests` ร่วมกับ `sys.dm_exec_query_plan` เพื่อดึง `query_plan` ของ session ที่น่าสงสัย
3.  คลิกที่ Link XML ในคอลัมน์ `query_plan` ในผลลัพธ์ของ DMV
4.  **ผลลัพธ์**: คุณจะเห็น Execution Plan ของงานที่กำลังวิ่งอยู่ทันที (Live Plan)
