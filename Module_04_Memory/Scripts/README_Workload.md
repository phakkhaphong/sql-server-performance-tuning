# Workload Scripts สำหรับ Demo Scripts

## Module 04: Memory

### `00_Workload_Buffer_Pool.sql`
**สำหรับ:** 
- `01_Buffer_Usage_By_DB.sql`
- `02_Page_Life_Expectancy.sql`

**วิธีใช้:**
1. เปิด Query Window ใหม่ (Session A)
2. รัน `00_Workload_Buffer_Pool.sql` ใน Session A
3. รอ 1-2 นาทีให้ workload อ่านข้อมูลเข้า Buffer Pool
4. เปิด Query Window อีกอัน (Session B)
5. รัน `01_Buffer_Usage_By_DB.sql` ใน Session B เพื่อดู Buffer Pool usage
6. รัน `02_Page_Life_Expectancy.sql` ใน Session B เพื่อดู PLE
7. หยุด workload โดยกด Cancel ใน Session A

**สิ่งที่ควรเห็น:**

**จาก `01_Buffer_Usage_By_DB.sql`:**
- `Cached Size (MB)` > 0 สำหรับ database ที่มี workload
- `Buffer Pool Percent` แสดงสัดส่วนการใช้ Buffer Pool ต่อ database

**จาก `02_Page_Life_Expectancy.sql`:**
- `PLE (Seconds)` แสดงเวลาที่ page อยู่ใน Buffer Pool
- Rule of thumb: PLE ควร > 300 seconds (5 minutes)
- PLE ที่ลดลงอย่างรวดเร็วบ่งชี้ Memory Pressure

**หมายเหตุ:**
- Workload นี้เน้นการอ่านข้อมูลเพื่อ populate Buffer Pool
- หากต้องการดู PLE ลดลง ให้รัน workload นานขึ้นหรือเพิ่ม memory pressure

