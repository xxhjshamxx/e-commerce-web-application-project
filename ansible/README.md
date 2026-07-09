# Ansible Web Setup

## الخطوات قبل التشغيل
1. عدّل `inventory/hosts.ini` وحط الـ IP و الـ user بتوع سيرفراتك الحقيقية بدل الوهمية.
2. عدّل `group_vars/all.yml`:
   - `new_user`: اسم اليوزر اللي عايز تنشئه.
   - `ssh_public_key`: حط محتوى ملف `id_rsa.pub` بتاعك بدل القيمة الوهمية.
3. تأكد إن عندك اتصال SSH شغال بالـ root أو يوزر عنده sudo على السيرفرات، لأن الـ playbook هيقفل الـ password login و الـ root login بعد أول تشغيل.

## التشغيل
```bash
ansible-playbook site.yml
```

## البنية
- `inventory/hosts.ini` → السيرفرات مقسّمة لمجموعتين: `nginx_servers` و `apache_servers`.
- `roles/common` → تحديث النظام، إنشاء يوزر، SSH key، تعطيل root login و password auth، فايروول، باكدجات أساسية.
- `roles/nginx` → تثبيت وتشغيل Nginx على مجموعة `nginx_servers`.
- `roles/apache` → تثبيت وتشغيل Apache على مجموعة `apache_servers`.

## ملاحظة
الـ playbook مبني على أساس Ubuntu/Debian (بيستخدم apt و ufw). لو السيرفرات بتاعتك CentOS/RHEL هيحتاج تعديل بسيط (yum/dnf و firewalld).
