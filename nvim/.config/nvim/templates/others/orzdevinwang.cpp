#include <bits/stdc++.h>
#define L(i, j, k) for (int i = (j); i <= (k); ++i)
#define R(i, j, k) for (int i = (j); i >= (k); --i)
#define ll long long
#define sz(a) ((int)(a).size())
#define vi vector<int>
#define pb emplace_back
#define me(a, x) memset(a, x, sizeof(a))
#define ull unsigned long long
#define ld __float128
using namespace std;
const int N = 1 << 21, mod = 1e9 + 7;
struct mint {
  int x;
  inline mint(int o = 0) { x = o; }
  inline mint &operator=(int o) { return x = o, *this; }
  inline mint &operator+=(mint o) {
    return (x += o.x) >= mod && (x -= mod), *this;
  }
  inline mint &operator-=(mint o) {
    return (x -= o.x) < 0 && (x += mod), *this;
  }
  inline mint &operator*=(mint o) { return x = (ll)x * o.x % mod, *this; }
  inline mint &operator^=(int b) {
    mint w = *this;
    mint ret(1);
    for (; b; b >>= 1, w *= w)
      if (b & 1)
        ret *= w;
    return x = ret.x, *this;
  }
  inline mint &operator/=(mint o) { return *this *= (o ^= (mod - 2)); }
  friend inline mint operator+(mint a, mint b) { return a += b; }
  friend inline mint operator-(mint a, mint b) { return a -= b; }
  friend inline mint operator*(mint a, mint b) { return a *= b; }
  friend inline mint operator/(mint a, mint b) { return a /= b; }
  friend inline mint operator^(mint a, int b) { return a ^= b; }
};

int len;
int a[N], n;
int ma[N];
mint dp[N];

int length;
struct S {
  int stk[N], top;
  mint sum;
  mint inc(int i) {
    while (top && ma[i] >= ma[stk[top]]) {
      --top;
      if (top)
        sum -= (ma[stk[top]] - ma[stk[top + 1]]) * dp[stk[top]];
    }
    stk[top + 1] = i;
    if (top) {
      sum += (ma[stk[top]] - ma[stk[top + 1]]) * dp[stk[top]];
    }
    ++top;
    return sum;
  }
} ds[2];
void Main() {
  cin >> length;
  string s;
  cin >> s;
  reverse(s.begin(), s.end());
  int same = true;
  L(i, 0, sz(s) - 1) same &= s[i] == s[0];
  if (same) {
    cout << sz(s) - 1 << '\n';
    return;
  }
  n = 0;
  len = 0;
  L(i, 0, sz(s) - 1) {
    ++len;
    if (i == sz(s) - 1 || s[i] != s[i + 1]) {
      a[++n] = len;
      len = 0;
    }
  }
  L(i, 0, n) dp[i] = 0;
  mint ans = 0;
  L(i, 1, n - 1)
  if ((n - i) % 2 == 0)
    dp[i] = (n - i) / 2;
  else
    dp[i] = a[n] + (n - i) / 2;
  L(i, 1, n)
  ma[i] = a[i] + i / 2;
  L(i, 0, 1) ds[i].top = 0, ds[i].sum = 0;
  R(i, n, 2) {
    dp[i - 1] += a[i] * dp[i];
    dp[i - 1] += ds[i & 1].inc(i);
  }
  cout << (dp[1] * a[1]).x << '\n';
}

int main() {
  ios ::sync_with_stdio(false);
  cin.tie(0);
  int t;
  cin >> t;
  while (t--)
    Main();
  return 0;
}
