# Lab: การวิเคราะห์ Wait Statistics และ CPU Pressure

## Prerequisites (สิ่งที่ต้องเตรียม)
- **Database**: `AdventureWorks2022` (ติดตั้งหรือ Restore เรียบร้อยแล้ว)
- **Tools**: SSMS (SQL Server Management Studio) และ OSTRESS (ถ้ามี) หรือใช้การเปิด Query Window หลายๆ หน้าต่าง

## Scenario (สถานการณ์)
สถานการณ์: บริษัท Proseware Inc. มีผู้ใช้งานร้องเรียนว่า "ระบบช้ามาก"
คำขอของคุณที่จะให้ทีม Infrastructure "เพิ่ม CPU" ถูกปฏิเสธ เนื่องจากกราฟ Monitor โชว์ว่า CPU Usage ใช้งานแค่ 60% เท่านั้น
คุณสงสัยว่าปัญหาไม่ได้อยู่ที่ความจุของ CPU แต่เป็นเรื่องของ **Waits** (การรอคอย) หรือ **Inefficient CPU usage** (Signal Waits)

## Objectives (วัตถุประสงค์)
1.  วิเคราะห์ **Wait Statistics** เพื่อระบุคอขวด (Bottleneck)
2.  แยกแยะระหว่าง **Resource Waits** (เช่น Disk/Network/Lock) และ **Signal Waits** (CPU Pressure)
3.  จำลองสถานการณ์และวิเคราะห์ Wait Type รูปแบบต่างๆ

---

## Exercise 1: การจำลองและวิเคราะห์ Resource Waits (ASYNC_NETWORK_IO / CXPACKET)

### Step 1: ดูค่า Baseline ปัจจุบัน
1.  เปิด SSMS และรัน Query เพื่อดู Wait Stats ปัจจุบัน:
    -- ใช้ Script ที่มีการกรองค่าที่ไม่จำเป็นออกแล้ว:
    เปิดและรัน: `LABS\Scripts\05_Wait_Stats_Deep_Dive.sql`
    -- Script นี้จะกรอง 'Benign' waits (เช่น LazyWriter, Checkpoint) ออก เพื่อให้โฟกัสที่ปัญหาจริง

### Step 2: สร้าง Workload (ASYNC_NETWORK_IO)
1.  เปิดไฟล์ `LABS\Scripts\01_Workload_NetworkWait.sql`
2.  รัน Script นี้ (Script จะดึงข้อมูลจำนวนมหาศาลแต่จะดึงแบบช้าๆ เพื่อจำลองพฤติกรรม Client Application ที่ประมวลผลไม่ทัน)
    *   *Note*: ใน SSMS, การเลือก "Grid Results" อาจทำให้เกิด Wait นี้ได้ถ้า Network ช้าหรือข้อมูลเยอะมาก

### Step 3: การวิเคราะห์ผล
1.  กลับไปรัน Query Wait Stats อีกครั้ง
2.  มองหา **ASYNC_NETWORK_IO**
    *   **การตีความ**: SQL Server พร้อมส่งข้อมูลแล้ว แต่ฝั่ง Client App (หรือ Network) รับข้อมูลไม่ทัน
    *   **การแก้ไข**: ต้องไปจูนที่ Application Code (ให้ดึงเฉพาะ Column ที่ใช้) หรือตรวจสอบ Network Bandwidth

---

## Exercise 2: การจำลอง High CPU (Signal Waits & SOS_SCHEDULER_YIELD)

### Step 1: สร้าง High CPU Workload
1.  เปิดไฟล์ `LABS\Scripts\02_Workload_HighCPU.sql`
2.  รัน Script นี้ (Script จะทำการคำนวณทางคณิตศาสตร์อย่างหนักวนลูปไปเรื่อยๆ)
3.  (Optional) รัน Script นี้ซ้ำในหลายๆ หน้าต่าง (New Query Window) เพื่อให้กิน CPU ครบทุก Core

### Step 2: การวิเคราะห์ผล
1.  Query จาก `sys.dm_os_wait_stats`
2.  คำนวณค่า **Signal Wait Ratio**:
    ```sql
    SELECT 
        wait_type, 
        (signal_wait_time_ms * 1.0 / wait_time_ms) * 100 AS SignalWaitPercent
    FROM sys.dm_os_wait_stats
    WHERE wait_time_ms > 1000
    ORDER BY SignalWaitPercent DESC;
    ```
3.  **SOS_SCHEDULER_YIELD**: ค่านี้บ่งบอกถึง Processor Pressure (Quantum exhaustion) คือ Thread ทำงานครบเวลา 4ms แล้วต้องยอมถอย (Yield) ให้ Thread อื่นทำงานต่อ

---

## Exercise 3: การวิเคราะห์แบบ Real-time ด้วย `sys.dm_exec_requests`

1.  ในขณะที่ Workload กำลังทำงาน ให้เปิดหน้าต่างใหม่
2.  รันคำสั่ง:
    ```sql
    SELECT 
        r.session_id,
        r.status,
        r.wait_type,
        r.wait_time,
        r.last_wait_type,
        t.text
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    WHERE r.session_id <> @@SPID AND r.is_user_process = 1;
    ```
3.  สังเกตคอลัมน์ `wait_type` ที่เปลี่ยนแปลงไปเรื่อยๆ แบบ Real-time

---

## Exercise 4: Advanced - เจาะลึก Yield Mechanism
*แบบฝึกหัดขั้นสูงนี้จะใช้ `04_Yield_Mechanism.sql` เพื่อดูการทำงานภายในของ SQL Server Scheduler*

### Concept (แนวคิด)
SQL Server ใช้ระบบ "Cooperative Multitasking" กล่าวคือ Thread จะทำงานบน CPU ได้รอบละไม่เกิน 4ms (Quantum) ถ้าทำงานไม่เสร็จ จะต้องยอมถอย (**Yield**) เพื่อให้คนอื่นได้ใช้ CPU บ้าง ซึ่งจะทำให้เกิด Wait Type ชื่อ `SOS_SCHEDULER_YIELD`

### Steps (ขั้นตอน)
1.  รัน High CPU Workload (`02_Workload_HighCPU.sql`) ใน Session แยกต่างหาก
2.  เปิดและรัน: `LABS\Scripts\04_Yield_Mechanism.sql`
3.  สังเกตค่า:
    *   **yield_count**: ตัวเลขจะวิ่งขึ้นเร็วมาก แสดงว่ามีการสลับ Context บ่อย
    *   **runnable_tasks_count**: ถ้าค่านี้ > 0 อย่างต่อเนื่อง ยืนยันได้เลยว่าเกิด CPU Pressure (มีงานรอต่อคิวในสถานะ "Runnable")
