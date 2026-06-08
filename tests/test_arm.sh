#!/usr/bin/env bash
# ARM64 Compatibility Test Suite
set -euo pipefail
PASS=0; FAIL=0; TOTAL=0

echo "══════════════════════════════════════════"
echo "  ARM64 Compatibility Test Suite"
echo "  Platform: $(uname -m)"
echo "══════════════════════════════════════════"
echo ""

# Test 1: Python
TOTAL=$((TOTAL+1))
echo -n "Python... "
python3 -c "
v=[1,0,-1,1,0,-1,1,1]
n=[60]
for x in v:
    if x==1:n.append(n[-1]+4)
    elif x==-1:n.append(n[-1]-4)
    else:n.append(n[-1])
assert n==[60,64,64,60,64,64,60,64,68]
" 2>/dev/null && { PASS=$((PASS+1)); echo "✅"; } || { FAIL=$((FAIL+1)); echo "❌"; }

# Test 2: C
TOTAL=$((TOTAL+1))
echo -n "C... "
gcc /dev/stdin -o /tmp/_arm_test 2>/dev/null << 'CEOF'
#include <stdio.h>
int main() {
    int v[]={1,0,-1,1,0,-1,1,1},n[9]={60};
    for(int i=0;i<8;i++){if(v[i]==1)n[i+1]=n[i]+4;else if(v[i]==-1)n[i+1]=n[i]-4;else n[i+1]=n[i];}
    return n[0]==60&&n[1]==64&&n[8]==68?0:1;
}
CEOF
/tmp/_arm_test 2>/dev/null && { PASS=$((PASS+1)); echo "✅"; } || { FAIL=$((FAIL+1)); echo "❌"; }

# Test 3: Rust
TOTAL=$((TOTAL+1))
echo -n "Rust... "
mkdir -p /tmp/_arm_rust/src
cat > /tmp/_arm_rust/Cargo.toml << 'RST'
[package]
name="armt";version="0.1.0";edition="2021"
RST
cat > /tmp/_arm_rust/src/main.rs << 'RRS'
fn main(){
let v=[1i8,0,-1,1,0,-1,1,1];
let mut n=vec![60u8];
for &x in &v{let l=*n.last().unwrap();n.push(if x==1{l+4}else if x==-1{l.wrapping_sub(4)}else{l})}
assert_eq!(n,vec![60,64,64,60,64,64,60,64,68]);
println!("Rust on ARM: {:?}",n);
}
RRS
cd /tmp/_arm_rust && cargo run 2>/dev/null | grep -q "60, 64, 64" && { PASS=$((PASS+1)); echo "✅"; } || { FAIL=$((FAIL+1)); echo "❌"; }

# Test 4: Go
TOTAL=$((TOTAL+1))
echo -n "Go... "
mkdir -p /tmp/_arm_go
cat > /tmp/_arm_go/main.go << 'GGO'
package main
import "fmt"
func main(){
    v:=[]int{1,0,-1,1,0,-1,1,1};n:=[]int{60}
    for _,x:=range v{l:=n[len(n)-1];if x==1{n=append(n,l+4)}else if x==-1{n=append(n,l-4)}else{n=append(n,l)}}
    fmt.Println(n)
}
GGO
cd /tmp/_arm_go && go mod init armt 2>/dev/null && go run main.go 2>/dev/null | grep -q "64.*64.*60" && { PASS=$((PASS+1)); echo "✅"; } || { FAIL=$((FAIL+1)); echo "❌"; }

# Test 5: JavaScript
TOTAL=$((TOTAL+1))
echo -n "JavaScript... "
node -e "
v=[1,0,-1,1,0,-1,1,1];n=[60];
v.forEach(x=>n.push(x===1?n[n.length-1]+4:x===-1?n[n.length-1]-4:n[n.length-1]));
console.log(n.join(','));
" 2>/dev/null | grep -q "64,64,60,64,64,60,64,68" && { PASS=$((PASS+1)); echo "✅"; } || { FAIL=$((FAIL+1)); echo "❌"; }

echo ""
echo "══════════════════════════════════════════"
echo "  RESULTS: $PASS/$TOTAL passed on ARM64"
echo "══════════════════════════════════════════"
[ "$FAIL" -eq 0 ]
