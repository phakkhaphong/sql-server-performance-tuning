# Workload Scripts สำหรับ Demo Scripts

## Module 11: Troubleshooting

### `00_Workload_Mixed_Stress.sql`
**สำหรับ:** 
- `01_Server_Health_Check.sql`
- `02_Quick_Wait_Analysis.sql`
- `03_Active_Blocking.sql`
- `04_Top_Resource_Queries.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_Mixed_Stress.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload สร้างกิจกรรมต่างๆ
4. เปิด Query Window อีกอัน (Session B)
5. รัน demo scripts ต่างๆ ใน Session B:
   - `01_Server_Health_Check.sql` - ตรวจสอบ CPU, Memory, Disk
   - `02_Quick_Wait_Analysis.sql` - วิเคราะห์ wait statistics
   - `03_Active_Blocking.sql` - ตรวจสอบ blocking (ถ้ามี)
   - `04_Top_Resource_Queries.sql` - หา queries ที่ใช้ resource สูง
6. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**

**จาก `01_Server_Health_Check.sql`:**
- CPU usage, Memory pressure, Disk latency
- Recent errors (ถ้ามี)

**จาก `02_Quick_Wait_Analysis.sql`:**
- Top wait types
- Resource waits vs Signal waits

**จาก `03_Active_Blocking.sql`:**
- Active blocking chains (ถ้ามี)
- Blocked sessions และ blocking sessions

**จาก `04_Top_Resource_Queries.sql`:**
- Top queries by CPU, Duration, Reads, Writes
- Query text และ execution plan

**หมายเหตุ:**
- Workload นี้รวม CPU, I/O, Memory, และ Write operations
- เหมาะสำหรับการทดสอบ troubleshooting workflow แบบครบวงจร

