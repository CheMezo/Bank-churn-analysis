select * from churn_clean;

# BQ
-- profil nasabah dan seberapa besar churn rate by demografi
select 
	geography,
    gender,
    count(*) as jumlah_nasabah,
    round(avg(age),1) as avg_umur,
    round(avg(balance),2) as avg_saldo,
    round(avg(estimated_salary),2) as avg_gaji,
    round(avg(tenure),1) as avg_tenure,
    round((sum(exited) * 100.0) / count(customer_id),2) as churn_rate_pct
from churn_clean
group by geography, gender
order by geography, gender;

select
	count(*) as jumlah_nasabah, 
    sum(exited) as nasabah_keluar,
    round(sum(exited) * 100.0/count(*),2) as churn_rate_keseluruhan
from churn_clean;

-- 2 nasabah yang bertahan vs churn
select 
    case 
		when exited = 1 then 'churn'
        else 'retained'
	end as status_nasabah,
	count(*) as jumlah_nasabah,
    round(avg(age),1) as avg_umur,
    round(avg(tenure),2) as avg_tenure,
    round(avg(num_of_products),2) as avg_jumlah_produk,
    round(avg(balance),2) as avg_saldo,
    round(sum(case when is_active_member = 1 then 1 else 0 end) * 100.0 / count(*),2) as active_member_pct
from churn_clean
group by exited;

-- 2.1 by gender
select 
	gender,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(case when is_active_member = 1 then 1 else 0 end) * 100.0 / count(*),2) as active_member_pct,
    round(sum(exited)*100.0 / count(*), 2) as churn_rate
from churn_clean
group by gender;

-- 2.2 by geography
select 
	geography,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(case when is_active_member = 1 then 1 else 0 end) * 100.0 / count(*),2) as active_member_pct,
    round(sum(exited)*100.0 / count(*) , 2) as churn_rate
from churn_clean
group by geography;

-- 2.3 by jumlah produk
select 
	num_of_products,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(exited)*100.0 / count(*), 2) as churn_rate
from churn_clean
group by num_of_products
order by num_of_products;

-- 2.4 by status aktif
select 
	case when is_active_member = 1 then 'Aktif' else 'Tidak aktif' end as status_aktif,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(exited)*100.0 / count(*), 2) as churn_rate
from churn_clean
group by is_active_member;

-- 2.5 by kelompok usia
select 
	case 
		when age is null then 'Tidak diketahui'
		when age < 30 then '<30'
        when age < 40 then '30-39'
        when age < 50 then '40-49'
        when age < 60 then '50-59'
		else '60+'
	end as kategori_usia,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(exited)*100.0 / count(*), 2) as churn_rate
from churn_clean
group by kategori_usia
order by min(age);

-- 2.6 by tenure (tahun)
select 
	tenure,
    count(*) as jumlah_nasabah,
    sum(exited) as jumlah_churn,
    round(sum(exited)*100.0 / count(*), 2) as churn_rate
from churn_clean
group by tenure
order by tenure;

-- 3 perilaku by geography
select 
	geography,
    count(*) as jumlah_nasabah,
    round(avg(balance),2) as avg_saldo,
    round(avg(num_of_products),2) as  avg_jumlah_produk,
    sum(is_active_member) as jumlah_active_nasabah,
    round(sum(case when is_active_member = 1 then 1 else 0 end) * 100.0 / count(*),2) as active_nasabah_rate,
    sum(exited) as jumlah_nasabah_churn,
    round(sum(case when exited = 1 then 1 else 0 end) * 100.0 / count(*),2) as churn_rate,
    round(avg(balance = 0) * 100, 2) as pct_saldo_nol,
	round(avg(nullif(balance, 0)), 2) AS avg_saldo_tanpa_nol
from churn_clean
group by geography;

-- 4 saldo hilang karena churn
select 
	sum(balance) as total_saldo_seluruh_nasabah,
    (select sum(balance) from churn_clean where exited = 1) as saldo_churn,
	sum(exited) as nasabah_churn,
    round(sum(exited)*100.0 / count(*),2) as churn_nasabah_pct
from churn_clean;

select max(balance), min(balance) from churn_clean;

-- 4.1
select 
	case 
		when balance = 0 then 'saldo 0'
        when balance < 30000 then 'Kecil'
        when balance < 120000 then 'Sedang'
        else 'Besar'
	end as kategori_saldo,
	count(*) as jumlah_nasabah,
	sum(exited) as total_churn,
	round(sum(exited)*100.0 / count(*),2) as churn_pct,
	round(avg(balance),2) as avg_saldo,
    sum(balance) as total_saldo_seluruh_nasabah,
	sum(case 
			when exited = 1 then balance else 0 end) as total_saldo_hilang,
	round(sum(case when exited = 1 then balance else 0 end) * 100.0
      / (select sum(balance) from churn_clean where exited = 1), 2) as pct_dari_saldo_hilang
from churn_clean
group by kategori_saldo
order by churn_pct DESC;

-- 5 churn rate by category

select 
	count(*) as jumlah_nasabah,
    case 
		when num_of_products = 1 then '1 Produk'
        when num_of_products = 2 then '2 Produk'
        else '3-4 Produk'
	end as kategori_produk,
	case 
		when age < 30 then '<30'
        when age < 40 then '30-39'
        when age < 50 then '40-49'
        when age < 60 then '50-59'
		else '60+'
	end as kategori_usia,
    case
		when is_active_member = 1 then 'Aktif' else 'Tidak aktif' end as status_aktif,
	round(avg(num_of_products),2) as avg_produk,
	sum(exited) as jumlah_churn,
    round(sum(exited)*100.0 / count(*),2) as churn_rate,
    round(sum(case when exited= 1 then balance else 0 end) ,2) as saldo_hilang,
    round(avg(tenure),2) as avg_tenure
from churn_clean
where age is not null
group by kategori_produk, kategori_usia, status_aktif
order by churn_rate desc;




