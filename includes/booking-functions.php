<?php
function bogie_code(string $category, string $gender): string {
    $map = ['Teacher'=>['Male'=>'B1','Female'=>'B2'], 'Student'=>['Male'=>'B3','Female'=>'B4'], 'Staff'=>['Male'=>'B5','Female'=>'B6']];
    if (!isset($map[$category][$gender])) throw new RuntimeException('This category and gender allocation is not available.');
    return $map[$category][$gender];
}
function allocate_seat(PDO $pdo, int $scheduleId, string $date, string $category, string $gender): array {
    $sql = 'SELECT s.seat_id,s.seat_number,b.bogie_code FROM schedules sc JOIN trains t ON t.train_id=sc.train_id JOIN bogies b ON b.train_id=t.train_id JOIN seats s ON s.bogie_id=b.bogie_id WHERE sc.schedule_id=? AND b.category=? AND b.gender=? AND b.is_active=1 AND s.is_active=1 AND NOT EXISTS (SELECT 1 FROM bookings x WHERE x.schedule_id=sc.schedule_id AND x.journey_date=? AND x.seat_id=s.seat_id AND x.status="Confirmed") ORDER BY b.bogie_code,s.seat_number LIMIT 1 FOR UPDATE';
    $stmt = $pdo->prepare($sql); $stmt->execute([$scheduleId,$category,$gender,$date]); $seat=$stmt->fetch();
    if (!$seat) throw new RuntimeException('No seats remain in your category and gender bogie for that journey.');
    return $seat;
}
