# Product Requirement Document (PRD)
**Project:** Smart Class Check-in & Learning Reflection App

## 1. Problem Statement
[cite_start]มหาวิทยาลัยต้องการระบบเพื่อยืนยันการเข้าเรียนของนักศึกษาอย่างแท้จริงว่าอยู่ในห้องเรียนจริง และมีการติดตามการมีส่วนร่วมในคลาสเรียนผ่านการสะท้อนความคิด (Reflection) [cite: 7, 8, 10, 11]

## 2. Target User
[cite_start]นักศึกษามหาวิทยาลัยที่ต้องเข้าร่วมคลาสเรียน [cite: 8]

## 3. Feature List
- [cite_start]**GPS Location:** บันทึกพิกัดตำแหน่งของผู้ใช้งานเพื่อยืนยันสถานที่ 
- [cite_start]**QR Code Scanner:** สแกนคิวอาร์โค้ดประจำวิชาเพื่อยืนยันตัวตน 
- [cite_start]**Pre-class Reflection:** แบบฟอร์มประเมินอารมณ์และความคาดหวังก่อนเรียน [cite: 14]
- [cite_start]**Post-class Reflection:** แบบฟอร์มสรุปสิ่งที่ได้เรียนรู้และข้อเสนอแนะหลังเลิกเรียน [cite: 18]
- **Cloud Database:** บันทึกและดึงข้อมูลผ่านระบบคลาวด์ 

## 4. User Flow
[cite_start]**Flow 1: ก่อนเรียน (Check-in) [cite: 14]**
1. ผู้ใช้กดปุ่ม "Check-in"
2. ระบบดึงข้อมูล GPS Location และ Timestamp อัตโนมัติ
3. ผู้ใช้สแกน QR Code ประจำคลาส
4. ผู้ใช้กรอกฟอร์ม: หัวข้อที่เรียนครั้งก่อน, สิ่งที่คาดหวังวันนี้, และให้คะแนนอารมณ์ (1-5)
5. กด Submit เพื่อบันทึกข้อมูลลง Database

[cite_start]**Flow 2: หลังเรียน (Check-out) [cite: 15, 16, 17, 18]**
1. ผู้ใช้กดปุ่ม "Finish Class"
2. ผู้ใช้สแกน QR Code
3. ระบบบันทึก GPS Location อัตโนมัติ
4. ผู้ใช้กรอกฟอร์ม: สิ่งที่ได้เรียนรู้วันนี้ และข้อเสนอแนะถึงผู้สอน
5. กด Submit เพื่อบันทึกข้อมูลลง Database

## 5. Data Fields
โครงสร้างข้อมูลที่จะจัดเก็บลงใน Database มีดังนี้:
- `timestamp_checkin` (DateTime): เวลาที่เข้าเรียน
- `gps_checkin` (String/GeoPoint): พิกัดตอนเข้าเรียน
- [cite_start]`previous_topic` (String): หัวข้อคลาสที่แล้ว [cite: 22]
- [cite_start]`expected_topic` (String): สิ่งที่คาดหวังวันนี้ [cite: 23]
- [cite_start]`mood_score` (Integer): ระดับอารมณ์ 1-5 [cite: 24, 25, 26, 29, 30, 31]
- `timestamp_checkout` (DateTime): เวลาที่เลิกเรียน
- `gps_checkout` (String/GeoPoint): พิกัดตอนเลิกเรียน
- [cite_start]`learned_today` (String): สิ่งที่ได้เรียนรู้วันนี้ [cite: 33]
- [cite_start]`feedback` (String): ข้อเสนอแนะถึงผู้สอน [cite: 34]

## 6. Tech Stack
- [cite_start]**Frontend / Framework:** Flutter (MVP build as Web App) [cite: 42, 69]
- [cite_start]**Database:** Firebase Cloud Firestore (แทน SQLite เพื่อให้ผ่านเกณฑ์ข้อ 4 ของอาจารย์) [cite: 70]
- [cite_start]**Deployment:** Firebase Hosting (นำ Flutter Web ขึ้นโฮสต์) [cite: 44, 73]