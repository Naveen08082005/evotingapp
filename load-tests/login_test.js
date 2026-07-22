import http from 'k6/http';
import { check, sleep } from 'k6';
import { SUPABASE_URL, COMMON_HEADERS, THRESHOLDS, SCENARIOS, generateHTMLReport } from './config.js';

export const options = {
  scenarios: {
    login_scenario: SCENARIOS.load_50,
  },
  thresholds: THRESHOLDS,
};

export default function () {
  const loginUrl = `${SUPABASE_URL}/auth/v1/token?grant_type=password`;
  const payload = JSON.stringify({
    email: 'test@example.com',
    password: 'Test@12345',
  });

  const res = http.post(loginUrl, payload, { headers: COMMON_HEADERS });

  check(res, {
    'status is 200': (r) => r.status === 200,
    'access_token received': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.access_token !== undefined;
      } catch (e) {
        return false;
      }
    },
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/summary_login_test.json': JSON.stringify(data),
    'results/report_login_test.html': generateHTMLReport(data, 'User Login API Load Test'),
  };
}
