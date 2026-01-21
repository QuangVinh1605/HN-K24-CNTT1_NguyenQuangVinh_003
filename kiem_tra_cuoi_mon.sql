drop database if exists kiem_tra_cuoi_mon;
create database kiem_tra_cuoi_mon;
use kiem_tra_cuoi_mon;
-- bảng 1: guests
create table guests (
guest_id int primary key auto_increment,
full_name varchar(100) not null,
email varchar(100) unique not null,
phone varchar(20),
points int default 0 check (points >= 0)
);

-- bảng 2: guest_profiles
create table guest_profiles (
profile_id int primary key auto_increment,
guest_id int unique,
address varchar(255),
birthday date,
national_id varchar(20) unique not null,
foreign key (guest_id) references guests(guest_id)
);

-- bảng 3: rooms
create table rooms (
room_id int primary key auto_increment,
room_name varchar(100) not null,
room_type enum('standard', 'deluxe', 'suite'),
price_per_night decimal(15,2) not null check (price_per_night > 0),
room_status enum('available','occupied','maintenance')
);

-- bảng 4: bookings
create table bookings (
booking_id int primary key auto_increment,
guest_id int,
check_in_date datetime,
check_out_date datetime,
total_charge decimal(15,2),
booking_status enum('completed','pending','cancelled'),
foreign key (guest_id) references guests(guest_id)
);

-- bảng 5: room_log
create table room_log (
log_id int primary key auto_increment,
room_id int,
action_type enum('check-in','check-out','maintenance'),
change_note text,
logged_at datetime default current_timestamp,
foreign key (room_id) references rooms(room_id)
);

-- chèn dữ liệu
insert into guests (guest_id, full_name, email, phone, points) values
(1,'nguyen van a','anv@gmail.com','901234567', 150),
(2,'tran thi b','btt@gmail.com','912345678',500),
(3,'le van c','cle@yahoo.com','922334455',0),
(4,'pham minh d','dpham@hotmail.com','933445566',1000),
(5,'hoang minh e','ehoang@gmail.com','944556677',20);

insert into guest_profiles (profile_id, guest_id, address, birthday, national_id) values
(101,1,'123 le loi, q1, hcm','1990-05-15', '12345'),
(102,2,'456 nguyen hue, q1, hcm','1985-10-20', '23456'),
(103,3,'789 phan chu trinh, da nang','1995-12-01', '34567'),
(104,4,'101 hoang hoa tham, ha noi','1988-03-25', '45678'),
(105,5,'202 tran hung dao, can tho', '2000-10-07', '56789');

insert into rooms (room_id, room_name, room_type, price_per_night, room_status) values
(1, 'room 101', 'standard', 1500000, 'available'),
(2, 'room 102', 'deluxe', 2500000, 'occupied'),
(3, 'room 103', 'suite', 5000000, 'available'),
(4, 'room 104', 'standard', 1200000, 'occupied'),
(5, 'room 105', 'deluxe', 2500000, 'maintenance');

insert into bookings (booking_id, guest_id, check_in_date, check_out_date, total_charge, booking_status) values
(1001, 1, '2023-11-15 10:30:00', '2023-11-18 12:00:00', 35500000, 'completed'),
(1002, 2, '2023-12-01 14:20:00', '2023-12-04 12:00:00', 28000000, 'completed'),
(1003, 1, '2024-01-10 09:15:00', '2024-01-11 12:00:00', 500000, 'pending'),
(1004, 3, '2023-05-20 16:45:00', '2023-05-22 12:00:00', 7000000, 'cancelled'),
(1005, 4, '2024-01-18 11:00:00', '2024-01-20 12:00:00', 1200000, 'completed');

insert into room_log (log_id, room_id, action_type, change_note, logged_at) values 
(1, 1, 'check-in', 'guest checked in', '2023-10-01 08:00:00'),
(2, 1, 'check-out', 'guest checked out', '2023-11-15 10:35:00'),
(3, 4, 'maintenance', 'room reported as damaged', '2023-11-20 15:00:00'),
(4, 2, 'check-in', 'new guest arrival', '2023-11-25 09:00:00'),
(5, 3, 'maintenance', 'schedule maintenance', '2023-12-01 13:00:00');

-- câu lệnh update & delete
update guests set points = points + 200 where email like '%@gmail.com';
delete from room_log where logged_at < '2023-11-10';
-- phan 1:
-- câu 1
select room_name, price_per_night, room_status from rooms 
where price_per_night > 1000000 or room_status = 'maintenance' or room_type = 'suite';
-- câu 2
select full_name, email from guests 
where email like '%@gmail.com' and points between 50 and 300;
-- câu 3
select * from bookings order by total_charge desc limit 3 offset 1;

-- phan 2:ruy vấn dữ liệu nâng cao
-- câu 1
select g.full_name, gp.national_id, b.booking_id, b.check_in_date, b.total_charge from guests g 
join guest_profiles gp on g.guest_id = gp.guest_id
join bookings b on g.guest_id = b.guest_id;

-- câu 2
select g.full_name, sum(b.total_charge) as total_spent from guests g
join bookings b on g.guest_id = b.guest_id
where b.booking_status = 'completed' group by g.guest_id, g.full_name having total_spent > 20000000;
-- câu 3
select * from rooms  
where price_per_night = (select max(price_per_night) from rooms) and room_id in (select distinct room_id from room_log where action_type = 'check-in');

-- phan 3 : INDEX VÀ VIEW
-- câu 1:
create index idx_booking_status_date 
on bookings (booking_status, check_in_date);
-- phan 4:

-- phan 5:stored procedure
delimiter //
create procedure sp_get_room_status(in p_room_id int)
begin
    declare v_status varchar(50);
    declare v_message varchar(100);

select room_status into v_status from rooms where room_id = p_room_id;
if v_status = 'available' then set v_message = 'phòng trống';
elseif v_status = 'occupied' then set v_message = 'đang có khách';
elseif v_status = 'maintenance' then set v_message = 'bảo trì';
else set v_message = 'không tìm thấy mã phòng';
end if;

    select v_message as status_message;
end //
delimiter ;
call sp_get_room_status(1);


