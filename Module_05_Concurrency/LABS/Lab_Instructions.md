# Lab: Concurrency, Blocking และ Deadlocks

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`
- **Tools**: เปิดหน้าต่าง Query ใน SSMS อย่างน้อย 2 หน้าต่าง (Session A และ Session B)

## Scenario (สถานการณ์)
ผู้ใช้งานบ่นว่าแอปพลิเคชัน "ค้าง" (Freeze) บ่อยมาก คุณสงสัยว่าเป็นเรื่อง **Blocking** Chains
นอกจากนี้ Batch Job กลางคืนก็ทำงานล้มเหลวด้วย error "Transaction was deadlocked"

## Objectives (วัตถุประสงค์)
1.  จำลองสถานการณ์ Blocking Chain
2.  วิเคราะห์ Blocking โดยใช้ `sys.dm_exec_requests`
3.  จำลองสถานการณ์ Deadlock และดู Deadlock Graph

---

## Exercise 1: การวิเคราะห์ Blocking Chains

### Step 1: สร้างตัว Lock (Session A)
1.  เปิดไฟล์ `LABS\Scripts\01_Blocking_SessionA.sql`
2.  รัน Script
    *   Script นี้จะเริ่ม Transaction และทำการ Update ข้อมูลใน `Production.Product` **แต่ยังไม่ Commit**

### Step 2: ผู้เคราะห์ร้าย (Session B)
1.  เปิด **หน้าต่างใหม่** (`LABS\Scripts\02_Blocking_SessionB.sql`)
2.  รัน Script
    *   Script นี้พยายามจะ `SELECT` แถวเดียวกับที่ Session A ถือ Lock อยู่
    *   **ผลลัพธ์**: Query จะหมุนติ้ว (Hangs) เพราะต้องรอ Lock (LCK_M_S รอ LCK_M_X)

### Step 3: การวิเคราะห์ (Session C - Admin)
1.  เปิดหน้าต่างที่ 3
2.  รัน Script วิเคราะห์:
    ```sql
    SELECT 
        r.session_id, 
        r.blocking_session_id, 
        r.wait_type, 
        r.wait_time,
        t.text AS QueryText
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    WHERE r.blocking_session_id > 0;
    ```
    *   สังเกต column `blocking_session_id` เพื่อหาว่าใครคือต้นตอ (Head Blocker)
3.  **การแก้ไข**: กลับไปที่ Session A แล้วรัน `COMMIT TRANSACTION` จะเห็นว่า Session B ทำงานเสร็จทันที

---

## Exercise 2: การวิเคราะห์ Deadlocks

### Step 1: เตรียมการ Deadlock (Session A)
1.  เปิดไฟล์ `LABS\Scripts\03_Deadlock_SessionA.sql`
2.  รัน **Step 1** (Update Table A)
3.  **อย่าเพิ่ง** รัน Step 2

### Step 2: เตรียมการ Deadlock (Session B)
1.  เปิดไฟล์ `LABS\Scripts\04_Deadlock_SessionB.sql`
2.  รัน **Step 1** (Update Table B)

### Step 3: จุดระเบิด (Trigger Deadlock)
1.  กลับไปที่ **Session A** แล้วรัน **Step 2** (Update Table B) -> *Session จะค้างเพราะติด Lock จาก B*
2.  ไปที่ **Session B** แล้วรัน **Step 2** (Update Table A)
3.  **ผลลัพธ์**: SQL Server จะตรวจจับ Cycle นี้ (A รอ B และ B รอ A) และจะเลือกฆ่า Session หนึ่ง (Victim) พร้อมแจ้ง Error 1205

### Step 4: Deadlock Graph
1.  ดึงข้อมูลจาก Extended Events `system_health` หรือใช้ `sys.fn_get_error_details` (ถ้ามีการตั้งค่าไว้) เพื่อดู XML Deadlock Graph
    *   (หรือใช้ Advanced Script ใน Module 9 เพื่อจับภาพนี้ให้ชัดเจนขึ้น)

---

## Exercise 3: Advanced - การวิเคราะห์ Latch & Spinlock
*แบบฝึกหัดขั้นสูงนี้จะใช้ `08_Latch_Spinlock_Analysis.sql` เพื่อ Troubleshoot ปัญหาภายใน Engine*

### Concept (แนวคิด)
*   **Latches**: ตัวปกป้อง Memory Pages (คล้าย Lock แต่เบากว่าและไม่มี Transaction) การรอ Latch สูงๆ มักบ่งบอกถึง "Hot Pages" (เช่น ทุกคนแย่งกันเขียนหน้าสุดท้ายของ Index)
*   **Spinlocks**: การปกป้องข้อมูลระดับ CPU (Low-level) ถ้ามี Collision สูง แสดงว่าเกิด "CPU Pressure" ในโค้ดส่วนนั้นๆ

### Steps (ขั้นตอน)
1.  **คำเตือน**: Script นี้ใช้ `WAITFOR DELAY` และอาจมีการ Reset Stats ควรใช้ใน Lab เท่านั้น
2.  รัน: `LABS\Scripts\08_Latch_Spinlock_Analysis.sql`
3.  รอ 5 วินาที เพื่อให้ Script เก็บข้อมูลความเปลี่ยนแปลง (Delta)
4.  สังเกตผล:
    *   **Latch Class**: `BUFFER` (ปัญหา Page Contention) หรือ `ACCESS_METHODS_DATASET_PARENT` (ปัญหา Parallelism)
    *   **Spinlock Name**: `LOCK_HASH` (Lock Manager ทำงานหนัก) หรือ `MUTEX` (การรอ Internal Sync)
