#include <bits/stdc++.h>

using i64  = long long;
using u64  = unsigned long long;
using u32  = unsigned;
using u128 = unsigned __int128;

template <class T> constexpr T power(T a, u64 b, T res = 1) {
    for (; b != 0; b /= 2, a *= a) {
        if (b & 1) {
            res *= a;
        }
    }
    return res;
}

template <u32 P> constexpr u32 mulMod(u32 a, u32 b) {
    return u64(a) * b % P;
}

template <u64 P> constexpr u64 mulMod(u64 a, u64 b) {
    u64 res = a * b - u64(1.L * a * b / P - 0.5L) * P;
    res %= P;
    return res;
}

constexpr i64 safeMod(i64 x, i64 m) {
    x %= m;
    if (x < 0) {
        x += m;
    }
    return x;
}

constexpr std::pair<i64, i64> invGcd(i64 a, i64 b) {
    a = safeMod(a, b);
    if (a == 0) {
        return { b, 0 };
    }

    i64 s = b, t = a;
    i64 m0 = 0, m1 = 1;

    while (t) {
        i64 u = s / t;
        s -= t * u;
        m0 -= m1 * u;

        std::swap(s, t);
        std::swap(m0, m1);
    }

    if (m0 < 0) {
        m0 += b / s;
    }

    return { s, m0 };
}

template <std::unsigned_integral U, U P> struct ModIntBase {
  public:
    constexpr ModIntBase() : x(0) {}
    template <std::unsigned_integral T> constexpr ModIntBase(T x_) : x(x_ % mod()) {}
    template <std::signed_integral T> constexpr ModIntBase(T x_) {
        using S = std::make_signed_t<U>;
        S v     = x_ % S(mod());
        if (v < 0) {
            v += mod();
        }
        x = v;
    }

    constexpr static U mod() { return P; }

    constexpr U val() const { return x; }

    constexpr ModIntBase operator-() const {
        ModIntBase res;
        res.x = (x == 0 ? 0 : mod() - x);
        return res;
    }

    constexpr ModIntBase inv() const { return power(*this, mod() - 2); }

    constexpr ModIntBase& operator*=(const ModIntBase& rhs) & {
        x = mulMod<mod()>(x, rhs.val());
        return *this;
    }
    constexpr ModIntBase& operator+=(const ModIntBase& rhs) & {
        x += rhs.val();
        if (x >= mod()) {
            x -= mod();
        }
        return *this;
    }
    constexpr ModIntBase& operator-=(const ModIntBase& rhs) & {
        x -= rhs.val();
        if (x >= mod()) {
            x += mod();
        }
        return *this;
    }
    constexpr ModIntBase& operator/=(const ModIntBase& rhs) & { return *this *= rhs.inv(); }

    friend constexpr ModIntBase operator*(ModIntBase lhs, const ModIntBase& rhs) {
        lhs *= rhs;
        return lhs;
    }
    friend constexpr ModIntBase operator+(ModIntBase lhs, const ModIntBase& rhs) {
        lhs += rhs;
        return lhs;
    }
    friend constexpr ModIntBase operator-(ModIntBase lhs, const ModIntBase& rhs) {
        lhs -= rhs;
        return lhs;
    }
    friend constexpr ModIntBase operator/(ModIntBase lhs, const ModIntBase& rhs) {
        lhs /= rhs;
        return lhs;
    }

    friend constexpr std::istream& operator>>(std::istream& is, ModIntBase& a) {
        i64 i;
        is >> i;
        a = i;
        return is;
    }
    friend constexpr std::ostream& operator<<(std::ostream& os, const ModIntBase& a) {
        return os << a.val();
    }

    friend constexpr bool operator==(const ModIntBase& lhs, const ModIntBase& rhs) {
        return lhs.val() == rhs.val();
    }
    friend constexpr std::strong_ordering operator<=>(const ModIntBase& lhs,
                                                      const ModIntBase& rhs) {
        return lhs.val() <=> rhs.val();
    }

  private:
    U x;
};

template <u32 P> using ModInt   = ModIntBase<u32, P>;
template <u64 P> using ModInt64 = ModIntBase<u64, P>;

struct Barrett {
  public:
    Barrett(u32 m_) : m(m_), im((u64)(-1) / m_ + 1) {}

    constexpr u32 mod() const { return m; }

    constexpr u32 mul(u32 a, u32 b) const {
        u64 z = a;
        z *= b;

        u64 x = u64((u128(z) * im) >> 64);

        u32 v = u32(z - x * m);
        if (m <= v) {
            v += m;
        }
        return v;
    }

  private:
    u32 m;
    u64 im;
};

template <u32 Id> struct DynModInt {
  public:
    constexpr DynModInt() : x(0) {}
    template <std::unsigned_integral T> constexpr DynModInt(T x_) : x(x_ % mod()) {}
    template <std::signed_integral T> constexpr DynModInt(T x_) {
        int v = x_ % int(mod());
        if (v < 0) {
            v += mod();
        }
        x = v;
    }

    constexpr static void setMod(u32 m) { bt = m; }

    static u32 mod() { return bt.mod(); }

    constexpr u32 val() const { return x; }

    constexpr DynModInt operator-() const {
        DynModInt res;
        res.x = (x == 0 ? 0 : mod() - x);
        return res;
    }

    constexpr DynModInt inv() const {
        auto v = invGcd(x, mod());
        assert(v.first == 1);
        return v.second;
    }

    constexpr DynModInt& operator*=(const DynModInt& rhs) & {
        x = bt.mul(x, rhs.val());
        return *this;
    }
    constexpr DynModInt& operator+=(const DynModInt& rhs) & {
        x += rhs.val();
        if (x >= mod()) {
            x -= mod();
        }
        return *this;
    }
    constexpr DynModInt& operator-=(const DynModInt& rhs) & {
        x -= rhs.val();
        if (x >= mod()) {
            x += mod();
        }
        return *this;
    }
    constexpr DynModInt& operator/=(const DynModInt& rhs) & { return *this *= rhs.inv(); }

    friend constexpr DynModInt operator*(DynModInt lhs, const DynModInt& rhs) {
        lhs *= rhs;
        return lhs;
    }
    friend constexpr DynModInt operator+(DynModInt lhs, const DynModInt& rhs) {
        lhs += rhs;
        return lhs;
    }
    friend constexpr DynModInt operator-(DynModInt lhs, const DynModInt& rhs) {
        lhs -= rhs;
        return lhs;
    }
    friend constexpr DynModInt operator/(DynModInt lhs, const DynModInt& rhs) {
        lhs /= rhs;
        return lhs;
    }

    friend constexpr std::istream& operator>>(std::istream& is, DynModInt& a) {
        i64 i;
        is >> i;
        a = i;
        return is;
    }
    friend constexpr std::ostream& operator<<(std::ostream& os, const DynModInt& a) {
        return os << a.val();
    }

    friend constexpr bool operator==(const DynModInt& lhs, const DynModInt& rhs) {
        return lhs.val() == rhs.val();
    }
    friend constexpr std::strong_ordering operator<=>(const DynModInt& lhs, const DynModInt& rhs) {
        return lhs.val() <=> rhs.val();
    }

  private:
    u32            x;
    static Barrett bt;
};

template <u32 Id> Barrett DynModInt<Id>::bt = 998244353;

using Z = ModInt<1000000007>;

std::set<std::string> ss;

void dfs(std::string s) {
    if (ss.contains(s)) {
        return;
    }
    ss.insert(s);
    if (s.size() == 2) {
        return;
    }
    for (int i = 0; i + 2 < s.size(); i++) {
        if (s[i + 1] == s[i + 2]) {
            dfs(s.substr(0, i + 1) + s.substr(i + 2));
        } else {
            dfs(s.substr(0, i) + s.substr(i + 1));
        }
    }
}

void brute(std::string s) {
    ss.clear();
    dfs(s);
}

void solve() {
    int n;
    std::cin >> n;

    std::string s;
    std::cin >> s;

    // brute(s);

    // auto get = [&](int i, char c, int len, bool end = false) {
    //     if (i >= n) {
    //         return n + 1;
    //     }
    //     int j = s.find(c ^ 1, i);
    //     if (j == -1) {
    //         j = n;
    //     }
    //     if (end && j != n) {
    //         return n + 1;
    //     }
    //     if (j - i >= len) {
    //         return j;
    //     }
    //     if (end) {
    //         return n + 1;
    //     }
    //     len -= j - i;
    //     i = j;
    //     while (len && i < n) {
    //         std::string t;
    //         t += c ^ 1;
    //         t += c;
    //         j = s.find(t, i);
    //         if (j == -1) {
    //             return n + 1;
    //         }
    //         len--;
    //         i = j + 2;
    //     }
    //     i = s.find(c ^ 1, i);
    //     if (i == -1) {
    //         i = n;
    //     }
    //     return i;
    // };

    // auto check = [&](std::string t) {
    //     if (t.size() < 2) {
    //         return false;
    //     }
    //     if (t.back() != s.back()) {
    //         return false;
    //     }
    //     int i = 0;
    //     for (int l = 0, r = 0; l < t.size(); l = r) {
    //         while (r < t.size() && t[l] == t[r]) {
    //             r++;
    //         }
    //         int j = get(i, t[l], r - l, r == t.size());
    //         if (i > 0) {
    //             for (int x = i + 1; x < n; x++) {
    //                 j = std::min(j, get(x, t[l], r - l, r == t.size()));
    //             }
    //         }
    //         if (j > n) {
    //             return false;
    //         }
    //         i = j;
    //     }
    //     return true;
    // };

    // std::cout << ss.size() << "\n";
    // for (int mask = 0; mask < (1 << n); mask++) {
    //     std::string t;
    //     for (int i = 0; i < n; i++) {
    //         if (mask >> i & 1) {
    //             t += s[i];
    //         }
    //     }
    //     if (check(t) != ss.contains(t)) {
    //         if (ss.contains(t)) {
    //             ss.erase(t);
    //         } else {
    //             ss.insert(t);
    //         }
    //         std::cerr << t << " " << check(t) << "\n";
    //     }
    // }

    std::vector<int> a(n);
    for (int i = 0; i < n; i++) {
        a[i] = s[i] - '0';
    }

    std::vector<int> len(n + 1);
    for (int i = n - 1; i >= 0; i--) {
        len[i] = i < n - 1 && a[i] == a[i + 1] ? 1 + len[i + 1] : 1;
    }

    std::vector<std::vector<Z>> dp(n);
    for (int i = 0; i < n; i++) {
        if (i == 0 || a[i] != a[i - 1]) {
            dp[i].resize(len[i] + 1);
        }
    }

    Z ans = 0;
    for (int x = 0; x < 2; x++) {
        int i = 0;
        for (int l = 1; l <= n && i < n; l++) {
            int j;
            if (a[i] != x) {
                i += len[i];
                j = i + len[i];
            } else if (i == 0 && l <= len[0]) {
                j = len[i];
            } else {
                i += len[i];
                i += len[i];
                j = i + len[i];
            }
            if (j >= n) {
                break;
            }
            assert(a[j] != x);
            // std::cerr << "j : " << j << " " << len[0] << "\n";
            dp[j][1] += 1;
        }
    }

    int last = 0;
    while (last < n && a[n - 1] == a[n - 1 - last]) {
        last++;
    }

    std::vector<int> nxt(n), id(n);
    std::vector<int> vec[2];
    for (int x = 0; x < 2; x++) {
        std::vector<int> stk;
        int              cur = 0;
        for (int i = 0; i < n; i++) {
            if (a[i] == x && (i == 0 || a[i] != a[i - 1])) {
                id[i] = cur++;
                vec[a[i]].push_back(i);
            }
        }
        for (int i = n - 1; i >= 0; i--) {
            if (a[i] == x && (i == 0 || a[i] != a[i - 1])) {
                while (!stk.empty() && len[stk.back()] - id[stk.back()] <= len[i] - id[i]) {
                    stk.pop_back();
                }
                nxt[i] = stk.empty() ? n : stk.back();
                stk.push_back(i);
            }
        }
    }

    std::vector<Z> dd(n);
    for (int i = 1; i < n; i++) {
        if (a[i] == a[i - 1]) {
            continue;
        }

        // std::cerr << "i : " << i;
        // for (int l = 1; l <= len[i]; l++) {
        //     std::cerr << " " << dp[i][l];
        // }
        // std::cerr << " nxt : " << nxt[i];
        // std::cerr << "\n";

        dp[i][1] += dd[i];
        if (id[i] + 1 < vec[a[i]].size()) {
            dd[vec[a[i]][id[i] + 1]] += dd[i];
        }

        if (a[i] == a[n - 1]) {
            for (int l = 1; l <= std::min(len[i], last); l++) {
                ans += dp[i][l] * (last - l + 1);
            }
        }

        Z res = 0;
        // std::cerr << "len : " << len[i] << "\n";
        for (int l = 1; l <= len[i]; l++) {
            res += dp[i][l];
            if (i + len[i] < n && l < len[i]) {
                dp[i + len[i]][1] += res;
            }
        }
        if (nxt[i] == n) {
            if (i + len[i] < n) {
                dd[i + len[i]] += res;
            }
        } else {
            if (i + len[i] < n) {
                dd[i + len[i]] += res;
            }
            int j = nxt[i];
            int l = len[i] + id[j] - id[i];
            dp[j][l] += res;
            if (j + len[j] < n) {
                dd[j + len[j]] -= res;
            }
        }
        // for (int l = len[i] + 1, j = i + len[i]; j < n; l++) {
        //     j += len[j];
        //     if (j >= n) {
        //         break;
        //     }
        //     if (j == nxt[i]) {
        //         assert(a[j] == a[i]);
        //         assert(l == len[i] + id[j] - id[i]);
        //         dp[j][l] += res;
        //         break;
        //     }
        //     j += len[j];
        //     if (j >= n) {
        //         break;
        //     }
        //     assert(a[j] != a[i]);
        //     dp[j][1] += res;
        // }
    }

    if (last == n) {
        ans += n - 1;
    }

    std::cout << ans << "\n";
}

int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);

    int t;
    std::cin >> t;

    while (t--) {
        solve();
    }

    return 0;
}
