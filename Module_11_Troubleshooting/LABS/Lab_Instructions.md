# Lab: Troubleshooting "The Broken Server" (Capstone)

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022`
- **Tools**: หลายๆ Query Window เพื่อจำลอง User

## Scenario (สถานการณ์)
09:00 น. เช้าวันจันทร์ (เหตุการณ์สมมติ) โทรศัพท์ Helpdesk ดังไม่หยุด "ระบบช้ามาก ทำงานไม่ได้เลย"
หน้าที่ของคุณคือใช้ **Troubleshooting Workflow** เพื่อหาสาเหตุที่แท้จริง (Root Cause)
*Note: เราจะจำลองปัญหา 2 อย่างพร้อมกัน เพื่อความตื่นเต้น*

## Objectives (วัตถุประสงค์)
1.  รัน "Chaos Script" เพื่อพัง Server
2.  ทำตาม Workflow: Define -> Validate Health -> Check Waits -> Identify Root Cause
3.  จัดการปัญหา (Kill Session หรือ แก้ Code)

---

## Exercise 1: การวินิจฉัยโรค (Diagnosis)

### Step 1: สร้างความโกลาหล (Chaos)
1.  เปิดไฟล์ `LABS\Scripts\01_Chaos_Generator.sql` ใน **3-4 หน้าต่างแยกกัน**
2.  รันทุกหน้าต่างพร้อมกัน!
    *   Script นี้จะรันทั้ง Blocking, High CPU และ I/O มั่วไปหมด

### Step 2: ประยุกต์ใช้ Workflow
1.  **Check Health**: ดู PerfMon หรือ Task Manager (CPU 100% หรือไม่?)
2.  **Check Waits**: รัน `sys.dm_os_wait_stats` (เทียบ Delta) หรือดู `sys.dm_exec_requests`
    *   เห็น `LCK_M_X` ไหม? (Blocking)
    *   เห็น `SOS_SCHEDULER_YIELD` ไหม? (CPU)

### Step 3: การแก้ไข (Mitigation)
1.  หา `session_id` ที่เป็น **Head Blocker** (`blocking_session_id = 0` แต่ไป Block ชาวบ้าน)
2.  หา `session_id` ที่กิน `cpu_time` เยอะที่สุด
3.  **Action**: ทำการ KILL Session ที่เป็นตัวปัญหาซะ
    ```sql
    KILL <session_id>;
    ```
4.  ตรวจสอบว่าระบบกลับมาปกติหรือไม่

---

## Exercise 2: Advanced Tools (Optional)
สามารถใช้ Advanced Scripts ที่ Integrate เข้ามาเพื่อช่วยวิเคราะห์ได้:
*   `Module_01_Architecture_Scheduling_Waits\LABS\Scripts\04_Yield_Mechanism.sql` ถ้าสงสัยเรื่อง CPU
*   `Module_05_Concurrency\LABS\Scripts\08_Latch_Spinlock_Analysis.sql` ถ้าสงสัยเรื่อง Latch/Spinlock
*   ใช้ DMV (`sys.dm_exec_requests`, `sys.dm_exec_query_plan`) หรือ Query Store เพื่อดู Plan ของตัวที่กำลังรันอยู่ (แทนการอ้างถึง Script เฉพาะ)
