import http from 'k6/http';
import { check, sleep } from 'k6';
import { SUPABASE_URL, COMMON_HEADERS, getAuthHeaders, THRESHOLDS, SCENARIOS, generateHTMLReport } from './config.js';

export const options = {
  scenarios: {
    vote_scenario: SCENARIOS.smoke_10,
  },
  thresholds: THRESHOLDS,
};

export function setup() {
  const loginUrl = `${SUPABASE_URL}/auth/v1/token?grant_type=password`;
  const loginPayload = JSON.stringify({
    email: 'test@example.com',
    password: 'Test@12345',
  });

  const loginRes = http.post(loginUrl, loginPayload, { headers: COMMON_HEADERS });
  let token = null;
  if (loginRes.status === 200) {
    token = JSON.parse(loginRes.body).access_token;
  }

  const candUrl = `${SUPABASE_URL}/rest/v1/candidates?select=id,name,position`;
  const candRes = http.get(candUrl, { headers: getAuthHeaders(token) });
  let candidates = [];
  if (candRes.status === 200) {
    candidates = JSON.parse(candRes.body);
  }

  return { token: token, candidates: candidates };
}

export default function (data) {
  if (!data || !data.token) return;

  const authHeaders = getAuthHeaders(data.token);

  // 1. Candidate List API Call
  const candUrl = `${SUPABASE_URL}/rest/v1/candidates?select=*`;
  const candRes = http.get(candUrl, { headers: authHeaders });

  check(candRes, {
    'candidate list status is 200': (r) => r.status === 200,
  });

  // 2. Results API Call
  const resultsUrl = `${SUPABASE_URL}/rest/v1/candidates?select=id,name,position,vote_count&order=vote_count.desc`;
  const resultsRes = http.get(resultsUrl, { headers: authHeaders });

  check(resultsRes, {
    'results API status is 200': (r) => r.status === 200,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/summary_vote_test.json': JSON.stringify(data),
    'results/report_vote_test.html': generateHTMLReport(data, 'Candidate List & Results API Load Test'),
  };
}
