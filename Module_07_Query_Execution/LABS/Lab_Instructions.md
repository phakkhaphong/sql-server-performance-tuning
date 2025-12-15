# Lab: Query Execution และ Internal Warnings

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`

## Scenario (สถานการณ์)
Developer บ่นว่า Query ของเขา "ไม่ยอมใช้ Index" (กลายเป็น Index Scan) ทั้งๆ ที่เงื่อนไขใน WHERE clause ก็กรองด้วย Primary Key หรือ Indexed Column
คุณตรวจสอบแล้วสงสัยว่าเป็นเรื่อง **Implicit Conversion** (การแปลง Type แฝง)

## Objectives (วัตถุประสงค์)
1.  จำลองปัญหา Implicit Conversion โดยการใช้ Data Type ที่ไม่ตรงกัน
2.  สังเกต **Yellow Warning** (CONVERT_IMPLICIT) ใน Execution Plan
3.  แก้ไข Query ให้ Data Type ตรงกัน

---

## Exercise 1: Implicit Conversion

### Step 1: สร้างปัญหา (Scan)
1.  เปิดไฟล์ `Module_07_Query_Execution\Scripts\00_Workload_Implicit_Conversions.sql`
2.  รัน **Step 1**
    *   Query นี้จะกรอง `NationalIDNumber` (ที่เป็น `NVARCHAR`) แต่ส่งค่าเข้าไปเป็น `INT`
    *   **กลไก**: SQL Server จะต้องแปลงค่าใน *Column* ให้เป็นตัวเลขเพื่อให้เทียบกันได้ (ตามลำดับความใหญ่ของ Data Type)
    *   **ผลลัพธ์**: เกิด `Index Scan` (เพราะต้องแปลงข้อมูลทุกแถวในตารางมาเช็ค) ทำให้ช้า

### Step 2: การวิเคราะห์
1.  ดูที่ Execution Plan (Ctrl+M)
2.  มองหา **เครื่องหมายตกใจสีเหลือง (Warning)** บน Operator `SELECT` หรือ `Index Scan`
3.  คลิกขวาเลือก "Properties" -> ดูหัวข้อ "PlanAffectingConvert" จะเห็นว่ามีการเตือนเรื่อง Convert Implicit

### Step 3: วิธีแก้ไข (Seek)
1.  รัน **Step 2**
    *   ส่งค่า Parameter เป็น String (ใส่ Single Quotes ครอบ) ให้ตรงกับ Type ของ Column
    *   **กลไก**: ไม่จำเป็นต้องแปลงค่าใน Column อีกต่อไป
    *   **ผลลัพธ์**: ได้ `Index Seek` ทันที

---

## Exercise 2: การวิเคราะห์ Live Query Statistics (Optional)
1.  กดปุ่ม "Include Live Query Statistics" ใน SSMS Toolbar
2.  รัน Query ที่ช้า (Step 1) อีกครั้ง
3.  สังเกตการไหลของข้อมูล (เส้นประ) จาก Operator หนึ่งไปสู่อีก Operator หนึ่งแบบ Real-time

---

## Exercise 3: Advanced - เจาะลึก Query Optimizer (Conceptual)
ในแบบฝึกหัดขั้นสูงนี้ ให้โฟกัสที่การใช้เครื่องมือใน SSMS มากกว่าการอ้างถึง Script เฉพาะไฟล์

### Live Query Statistics
1.  เลือก Query ที่ทำงานช้าหรือใช้ Cross Join เพื่อจำลอง Long-running query
2.  เปิดโหมด **Live Query Statistics** ใน SSMS
3.  ดูจำนวน Logical Rows ที่ไหลจาก Leaf node (ขวา) ขึ้นไปยัง Root (ซ้าย) แบบสดๆ วิธีนี้ช่วยให้รู้เลยว่า Query ค้างอยู่ที่จุดไหน

### Optimizer Transformation Rules (แนวคิด)
1.  ศึกษา Execution Plan XML และเอกสาร Query Processing Architecture ของ Microsoft เพื่อทำความเข้าใจว่า Optimizer แปลง Logical Tree ไปเป็น Physical Plan อย่างไร
2.  สังเกตการเลือก Join Type, Access Method และการใช้ Statistics/CE Model ในแผนที่แตกต่างกัน
