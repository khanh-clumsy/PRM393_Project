# FSchool Web

React + Vite cho khu vực quản trị viên và giáo viên. Web giáo viên nhận nghiệp vụ nhập điểm; mobile đã ẩn UI nhập điểm. Gọi API tại `http://localhost:5088`.

## Chạy local

1. API: `cd api && dotnet run` (http://localhost:5088)
2. Web: `cd web && npm install && npm run dev` (http://localhost:5174)
3. Đăng nhập tài khoản quản trị viên hoặc giáo viên (`phoneNumber` + `password`)

## Scripts

- `npm run dev` — dev server cố định port 5174
- `npm run build` — build production
- `npm run lint` — oxlint
