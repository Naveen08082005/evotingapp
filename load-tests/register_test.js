import http from 'k6/http';
import { check, sleep } from 'k6';
import { SUPABASE_URL, COMMON_HEADERS, THRESHOLDS, SCENARIOS, generateHTMLReport } from './config.js';

export const options = {
  scenarios: {
    register_scenario: SCENARIOS.load_50,
  },
  thresholds: THRESHOLDS,
};

export default function () {
  const vuId = __VU;
  const iterId = __ITER;
  const timestamp = Date.now();
  const randomRegNo = `REG_${timestamp}_${vuId}_${iterId}`;
  const randomEmail = `loadtest_${timestamp}_${vuId}_${iterId}@evoting.local`;

  const signupUrl = `${SUPABASE_URL}/auth/v1/signup`;
  const payload = JSON.stringify({
    email: randomEmail,
    password: 'TestPassword@123',
    data: {
      full_name: `Load Test User ${vuId}`,
      register_number: randomRegNo,
      mobile_number: '9876543210',
      department: 'Computer Science',
      role: 'student',
    },
  });

  const res = http.post(signupUrl, payload, { headers: COMMON_HEADERS });

  check(res, {
    'status is 200': (r) => r.status === 200,
    'user object received': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.user !== undefined || body.id !== undefined;
      } catch (e) {
        return false;
      }
    },
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/summary_register_test.json': JSON.stringify(data),
    'results/report_register_test.html': generateHTMLReport(data, 'User Registration API Load Test'),
  };
}
