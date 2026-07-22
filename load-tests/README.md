# E-Voting System — k6 Load Testing Suite

Production-grade API performance testing suite built using **Grafana k6** for the Flutter + Supabase E-Voting System.

---

## 📁 Directory Layout

```text
load-tests/
├── bin/
│   └── k6.exe                   # Executable standalone k6 binary
├── k6.exe                       # Executable binary reference
├── config.js                    # Base configuration, thresholds & stages
├── login_test.js                # User Authentication API load test
├── register_test.js             # User Registration API load test
├── vote_test.js                 # Candidate List & Results API load test
├── full_system_test.js          # End-to-end user journey scenario
├── run_load_tests.ps1          # PowerShell automation runner
├── README.md                    # Suite documentation
└── results/                     # Generated JSON & HTML reports
```

---

## 🚀 Execution Commands

### Via npm scripts:
```bash
# Run all load tests
npm run test:load

# Run specific load tests
npm run test:load:login
npm run test:load:register
npm run test:load:vote
npm run test:load:full
```

### Via PowerShell:
```powershell
# Run all tests
.\load-tests\run_load_tests.ps1 -TestName all

# Run individual test scenario
.\load-tests\run_load_tests.ps1 -TestName login
.\load-tests\run_load_tests.ps1 -TestName register
.\load-tests\run_load_tests.ps1 -TestName vote
.\load-tests\run_load_tests.ps1 -TestName full
```

---

## 📊 Configured SLA & Thresholds

- **95th Percentile Latency**: `< 500ms` (`http_req_duration: ['p(95)<500']`)
- **Error Rate**: `< 1%` (`http_req_failed: ['rate<0.01']`)

---

## 📈 VU Load Scenarios

- **Smoke Test (10 VUs)**: Ramp up to 10 VUs over 5s, hold 15s, ramp down over 5s.
- **Load Test (50 VUs)**: Ramp up to 50 VUs over 10s, hold 20s, ramp down over 10s.
- **Stress Test (100 VUs)**: Ramp up to 100 VUs over 10s, hold 20s, ramp down over 10s.
- **Soak Test (500 VUs)**: Ramp up to 500 VUs over 15s, hold 30s, ramp down over 15s.
