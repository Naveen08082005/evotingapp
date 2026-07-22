import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { SUPABASE_URL, COMMON_HEADERS, getAuthHeaders, THRESHOLDS, SCENARIOS, generateHTMLReport } from './config.js';

export const options = {
  scenarios: {
    system_load_50: SCENARIOS.load_50,
  },
  thresholds: THRESHOLDS,
};

export default function () {
  const vuId = __VU;
  const iterId = __ITER;
  const timestamp = Date.now();
  const regNo = `REG_${timestamp}_${vuId}_${iterId}`;
  const userEmail = `user_${timestamp}_${vuId}_${iterId}@evoting.test`;
  const userPassword = 'TestPassword@123';

  let jwtToken = null;

  group('01_User_Registration', function () {
    const signupUrl = `${SUPABASE_URL}/auth/v1/signup`;
    const payload = JSON.stringify({
      email: userEmail,
      password: userPassword,
      data: {
        full_name: `System User ${vuId}_${iterId}`,
        register_number: regNo,
        mobile_number: '9876543210',
        department: 'Computer Science',
        role: 'student',
      },
    });

    const res = http.post(signupUrl, payload, { headers: COMMON_HEADERS });

    const isSuccess = check(res, {
      'registration status is 200': (r) => r.status === 200,
    });

    if (isSuccess && res.body) {
      try {
        const body = JSON.parse(res.body);
        jwtToken = body.access_token;
      } catch (e) {}
    }
  });

  sleep(1);

  group('02_User_Login', function () {
    const loginUrl = `${SUPABASE_URL}/auth/v1/token?grant_type=password`;
    const payload = JSON.stringify({
      email: userEmail,
      password: userPassword,
    });

    const res = http.post(loginUrl, payload, { headers: COMMON_HEADERS });

    const isSuccess = check(res, {
      'login status is 200': (r) => r.status === 200,
    });

    if (isSuccess && res.body) {
      try {
        const body = JSON.parse(res.body);
        jwtToken = body.access_token;
      } catch (e) {}
    }
  });

  sleep(1);

  if (jwtToken) {
    const authHeaders = getAuthHeaders(jwtToken);

    group('03_Candidate_List', function () {
      const url = `${SUPABASE_URL}/rest/v1/candidates?select=*`;
      const res = http.get(url, { headers: authHeaders });

      check(res, {
        'candidate list status is 200': (r) => r.status === 200,
      });
    });

    sleep(1);

    group('04_Results_API', function () {
      const url = `${SUPABASE_URL}/rest/v1/candidates?select=id,name,position,vote_count&order=vote_count.desc`;
      const res = http.get(url, { headers: authHeaders });

      check(res, {
        'results API status is 200': (r) => r.status === 200,
      });
    });
  }

  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/summary_full_system_test.json': JSON.stringify(data),
    'results/report_full_system_test.html': generateHTMLReport(data, 'Full User Journey System Load Test'),
  };
}
