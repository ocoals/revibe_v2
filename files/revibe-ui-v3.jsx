import { useState, useEffect } from "react";

const C = {
  bg: "#FAFAFA", white: "#FFFFFF", ink: "#262626", sec: "#555555", ter: "#8E8E8E",
  mute: "#C7C7CC", line: "#EFEFEF", lineDark: "#DBDBDB",
  primary: "#4F46E5", primarySoft: "#EEF2FF", violet: "#7C3AED",
  card: "0 0 0 0.5px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.04)",
};

const ph = {
  width: 375, height: 812, background: C.bg, borderRadius: 44,
  overflow: "hidden", position: "relative",
  boxShadow: "0 20px 60px rgba(0,0,0,0.15), 0 0 0 0.5px rgba(0,0,0,0.08)",
  fontFamily: "-apple-system, 'Apple SD Gothic Neo', sans-serif",
};

/* ── Icons ── */
const I = {
  grid: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6"><rect x="3" y="3" width="7.5" height="7.5" rx="1"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1"/></svg>,
  gridFill: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none"><rect x="3" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1.5"/></svg>,
  scan: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round"><path d="M7 3H5a2 2 0 00-2 2v2"/><path d="M17 3h2a2 2 0 012 2v2"/><path d="M7 21H5a2 2 0 01-2-2v-2"/><path d="M17 21h2a2 2 0 002-2v-2"/><circle cx="12" cy="12" r="3.5"/></svg>,
  scanFill: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M7 3H5a2 2 0 00-2 2v2"/><path d="M17 3h2a2 2 0 012 2v2"/><path d="M7 21H5a2 2 0 01-2-2v-2"/><path d="M17 21h2a2 2 0 002-2v-2"/><circle cx="12" cy="12" r="3.5" fill={c}/></svg>,
  cal: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M3 10h18"/><path d="M8 2v4"/><path d="M16 2v4"/></svg>,
  calFill: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none"><rect x="3" y="4" width="18" height="18" rx="2.5"/><rect x="3" y="4" width="18" height="7" rx="2.5" fill={c}/><rect x="3" y="9" width="18" height="2" fill={c} opacity="0.3"/><circle cx="8" cy="3" r="1.5" fill={c}/><circle cx="16" cy="3" r="1.5" fill={c}/></svg>,
  user: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6"><circle cx="12" cy="8" r="3.5"/><path d="M6 21v-1a6 6 0 0112 0v1"/></svg>,
  userFill: (c,s=22) => <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none"><circle cx="12" cy="8" r="4"/><path d="M5 21a7 7 0 0114 0H5z"/></svg>,
  plus: (c="#fff",s=18) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.5" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>,
  back: (c=C.ink) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M15 18l-6-6 6-6"/></svg>,
  right: (c=C.mute) => <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>,
  cam: (c=C.ter,s=24) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/></svg>,
  share: (c=C.sec) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round"><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>,
  ext: (c="#fff") => <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>,
  lock: (c=C.ter) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>,
  heart: (c=C.ink) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>,
  bookmark: (c=C.ink) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6"><path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/></svg>,
};

const SB = ({ dark }) => (
  <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"14px 28px 0", fontSize:15, fontWeight:600, color: dark?"#fff":C.ink }}>
    <span>9:41</span>
    <div style={{ display:"flex", gap:5, alignItems:"center" }}>
      <svg width="16" height="11" viewBox="0 0 16 11"><rect x="0" y="1" width="3" height="10" rx=".5" fill={dark?"#fff":C.ink} opacity=".4"/><rect x="4.5" y="3" width="3" height="8" rx=".5" fill={dark?"#fff":C.ink} opacity=".6"/><rect x="9" y=".5" width="3" height="10.5" rx=".5" fill={dark?"#fff":C.ink} opacity=".8"/><rect x="13" y="3" width="3" height="8" rx=".5" fill={dark?"#fff":C.ink}/></svg>
      <div style={{ width:24, height:11, border:`1.2px solid ${dark?"rgba(255,255,255,.5)":C.mute}`, borderRadius:3, position:"relative", marginLeft:2 }}>
        <div style={{ position:"absolute", top:2, left:2, width:14, height:5.5, background:dark?"#fff":C.ink, borderRadius:1.5 }}/>
      </div>
    </div>
  </div>
);

/* ── Data ── */
const W = [
  {id:1,color:"#2C3E50",cat:"아우터",name:"네이비 코트",h:180},
  {id:2,color:"#E8D5B7",cat:"상의",name:"크림 니트",h:140},
  {id:3,color:"#1A1A2E",cat:"하의",name:"블랙 슬랙스",h:165},
  {id:4,color:"#8B4513",cat:"신발",name:"브라운 로퍼",h:120},
  {id:5,color:"#F0EBE3",cat:"상의",name:"아이보리 셔츠",h:150},
  {id:6,color:"#4A6741",cat:"아우터",name:"카키 자켓",h:175},
  {id:7,color:"#C4A882",cat:"가방",name:"탄 숄더백",h:130},
  {id:8,color:"#6B7B8D",cat:"하의",name:"그레이 데님",h:155},
];
const CATS=["전체","상의","하의","아우터","신발","가방"];
const RECENT=[
  {id:1,color:"#D4B896",score:91,label:"캐주얼 코디"},
  {id:2,color:"#8B9DAF",score:87,label:"오피스룩"},
  {id:3,color:"#A0826D",score:76,label:"데이트룩"},
  {id:4,color:"#6B8E7B",score:82,label:"스트릿"},
];

/* ══ Splash ══ */
const Splash = ({onDone}) => {
  useEffect(()=>{const t=setTimeout(onDone,1800);return()=>clearTimeout(t)},[]);
  return <div style={ph}>
    <div style={{height:"100%",background:C.primary,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center"}}>
      <div style={{opacity:0,animation:"fi .6s ease .3s forwards"}}>
        <div style={{display:"flex",alignItems:"center",gap:3}}>
          <span style={{fontSize:72,fontWeight:800,color:"#fff",fontFamily:"Georgia,serif",lineHeight:1}}>R</span>
          <div style={{display:"flex",flexDirection:"column",gap:7,marginTop:4}}>
            <div style={{width:13,height:13,borderRadius:"50%",background:"#fff"}}/>
            <div style={{width:13,height:13,borderRadius:"50%",background:"rgba(255,255,255,0.4)"}}/>
          </div>
        </div>
      </div>
      <p style={{fontSize:18,color:"rgba(255,255,255,0.55)",fontWeight:600,letterSpacing:6,marginTop:20,opacity:0,animation:"fi .6s ease .6s forwards",fontFamily:"Georgia,serif"}}>RE:VIBE</p>
    </div>
    <style>{`@keyframes fi{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}`}</style>
  </div>;
};

/* ══ Onboarding ══ */
const Onboarding = ({onDone}) => {
  const [p,setP]=useState(0);
  const sl=[
    {t:"인플루언서 코디,\n내 옷장으로 따라입기",s:"인스타에서 본 코디를 새 옷 없이\n이미 가진 옷으로 재현하세요",
     il:<div style={{width:200,height:200,borderRadius:100,background:"rgba(255,255,255,0.1)",display:"flex",alignItems:"center",justifyContent:"center"}}>
       <div style={{width:120,height:120,borderRadius:60,background:"rgba(255,255,255,0.12)",display:"flex",alignItems:"center",justifyContent:"center"}}>
         <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.2"><path d="M12 6a2 2 0 002-2c0-1-1-2-2-2s-2 1-2 2"/><path d="M12 6L4 16h16L12 6z"/><line x1="4" y1="16" x2="4" y2="20"/><line x1="20" y1="16" x2="20" y2="20"/><line x1="4" y1="20" x2="20" y2="20"/></svg>
       </div>
     </div>},
    {t:"사진 한 장이면 끝,\n30초 옷장 등록",s:"AI가 배경을 제거하고\n색상과 카테고리를 자동 분석해요",
     il:<div style={{width:200,height:200,borderRadius:100,background:"rgba(255,255,255,0.1)",display:"flex",alignItems:"center",justifyContent:"center"}}>
       <div style={{width:120,height:120,borderRadius:60,background:"rgba(255,255,255,0.12)",display:"flex",alignItems:"center",justifyContent:"center"}}>
         {I.cam("#fff",56)}
       </div>
     </div>},
    {t:"AI 코디 매칭으로\n나만의 스타일 완성",s:"원하는 코디 사진만 올리면\n내 옷장에서 최적 조합을 찾아줘요",
     il:<div style={{width:200,height:200,borderRadius:100,background:"rgba(255,255,255,0.1)",display:"flex",alignItems:"center",justifyContent:"center"}}>
       <div style={{width:120,height:120,borderRadius:60,background:"rgba(255,255,255,0.12)",display:"flex",alignItems:"center",justifyContent:"center"}}>
         {I.scan("#fff",56)}
       </div>
     </div>},
  ];
  return <div style={ph}><div style={{height:"100%",background:C.primary,display:"flex",flexDirection:"column"}}>
    <SB dark/>
    <div style={{display:"flex",justifyContent:"flex-end",padding:"8px 20px 0"}}>
      <button onClick={onDone} style={{background:"none",border:"none",fontSize:14,color:"rgba(255,255,255,.45)",cursor:"pointer",padding:0}}>건너뛰기</button>
    </div>
    <div style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",padding:"0 32px",textAlign:"center"}}>
      <div style={{marginBottom:36}}>{sl[p].il}</div>
      <h1 style={{fontSize:22,fontWeight:700,color:"#fff",lineHeight:1.45,whiteSpace:"pre-line",margin:"0 0 12px",letterSpacing:-.3}}>{sl[p].t}</h1>
      <p style={{fontSize:14,color:"rgba(255,255,255,.55)",lineHeight:1.7,whiteSpace:"pre-line",margin:0}}>{sl[p].s}</p>
    </div>
    <div style={{padding:"0 24px 48px"}}>
      <div style={{display:"flex",justifyContent:"center",gap:6,marginBottom:20}}>
        {sl.map((_,i)=><div key={i} style={{width:i===p?20:6,height:6,borderRadius:3,background:i===p?"#fff":"rgba(255,255,255,.2)",transition:"all .3s"}}/>)}
      </div>
      <button onClick={()=>p<2?setP(p+1):onDone()} style={{width:"100%",padding:"15px",background:"#fff",border:"none",borderRadius:12,fontSize:15,fontWeight:700,color:C.primary,cursor:"pointer"}}>{p<2?"다음":"시작하기"}</button>
    </div>
  </div></div>;
};

/* ══ Login ══ */
const Login = ({onLogin}) => <div style={ph}><div style={{height:"100%",background:C.white,display:"flex",flexDirection:"column"}}>
  <SB/>
  <div style={{flex:1,display:"flex",flexDirection:"column",justifyContent:"center",padding:"0 24px"}}>
    <div style={{display:"flex",alignItems:"center",gap:3,marginBottom:24}}>
      <span style={{fontSize:40,fontWeight:800,color:C.primary,fontFamily:"Georgia,serif",lineHeight:1}}>R</span>
      <div style={{display:"flex",flexDirection:"column",gap:5,marginTop:2}}>
        <div style={{width:8,height:8,borderRadius:"50%",background:C.primary}}/>
        <div style={{width:8,height:8,borderRadius:"50%",background:C.primary,opacity:.35}}/>
      </div>
    </div>
    <h1 style={{fontSize:22,fontWeight:700,color:C.ink,margin:"0 0 6px",lineHeight:1.4}}>RE:VIBE에 오신 걸<br/>환영합니다</h1>
    <p style={{fontSize:14,color:C.ter,margin:"0 0 32px"}}>간편하게 시작하세요</p>
    <button onClick={onLogin} style={{width:"100%",padding:"14px",background:"#FEE500",border:"none",borderRadius:10,fontSize:15,fontWeight:600,color:"#1A1A1A",cursor:"pointer",marginBottom:10}}>카카오로 시작하기</button>
    <button onClick={onLogin} style={{width:"100%",padding:"14px",background:"#000",border:"none",borderRadius:10,fontSize:15,fontWeight:600,color:"#fff",cursor:"pointer"}}>Apple로 시작하기</button>
  </div>
  <p style={{textAlign:"center",fontSize:11,color:C.mute,padding:"0 24px 36px",lineHeight:1.7}}>
    시작하면 <span style={{textDecoration:"underline"}}>이용약관</span> 및 <span style={{textDecoration:"underline"}}>개인정보처리방침</span>에 동의합니다
  </p>
</div></div>;

/* ══ Wardrobe — Instagram-inspired ══ */
const WardrobeScr = () => {
  const [cat,setCat]=useState("전체");
  const filtered = cat==="전체"?W:W.filter(w=>w.cat===cat);
  const L=filtered.filter((_,i)=>i%2===0), R=filtered.filter((_,i)=>i%2===1);

  return <div style={{height:"100%",background:C.bg}}>
    <SB/>
    {/* Header — Instagram style */}
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 16px 0",background:C.white}}>
      <div style={{display:"flex",alignItems:"center",gap:3}}>
        <span style={{fontSize:20,fontWeight:800,color:C.primary,fontFamily:"Georgia,serif"}}>R</span>
        <div style={{display:"flex",flexDirection:"column",gap:2.5,marginTop:1}}>
          <div style={{width:4.5,height:4.5,borderRadius:"50%",background:C.primary}}/>
          <div style={{width:4.5,height:4.5,borderRadius:"50%",background:C.primary,opacity:.35}}/>
        </div>
        <span style={{fontSize:16,fontWeight:700,color:C.ink,marginLeft:6}}>내 옷장</span>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:4}}>
        <span style={{fontSize:12,color:C.ter}}>{W.length}/30</span>
      </div>
    </div>

    {/* Story-like category row (Instagram stories style) */}
    <div style={{display:"flex",gap:14,padding:"14px 16px",overflowX:"auto",background:C.white,borderBottom:`0.5px solid ${C.line}`}}>
      {CATS.map(c => {
        const active = cat===c;
        const count = c==="전체"?W.length:W.filter(w=>w.cat===c).length;
        return <div key={c} onClick={()=>setCat(c)} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:6,cursor:"pointer",flexShrink:0}}>
          <div style={{width:56,height:56,borderRadius:28,border:active?`2px solid ${C.primary}`:`2px solid ${C.line}`,padding:2,display:"flex",alignItems:"center",justifyContent:"center",transition:"all .2s"}}>
            <div style={{width:48,height:48,borderRadius:24,background:active?C.primarySoft:C.bg,display:"flex",alignItems:"center",justifyContent:"center"}}>
              <span style={{fontSize:14,fontWeight:700,color:active?C.primary:C.ter}}>{count}</span>
            </div>
          </div>
          <span style={{fontSize:11,color:active?C.ink:C.ter,fontWeight:active?600:400}}>{c}</span>
        </div>;
      })}
    </div>

    {/* Masonry grid */}
    <div style={{display:"flex",gap:3,padding:"3px",height:490,overflowY:"auto"}}>
      {[L,R].map((col,ci)=><div key={ci} style={{flex:1,display:"flex",flexDirection:"column",gap:3}}>
        {col.map(item=><div key={item.id} style={{background:item.color,height:item.h,position:"relative",overflow:"hidden"}}>
          <div style={{position:"absolute",bottom:0,left:0,right:0,padding:"20px 10px 8px",background:"linear-gradient(transparent,rgba(0,0,0,.4))"}}>
            <p style={{fontSize:10,color:"rgba(255,255,255,.6)",margin:"0 0 1px",fontWeight:500}}>{item.cat}</p>
            <p style={{fontSize:12,color:"#fff",margin:0,fontWeight:600}}>{item.name}</p>
          </div>
        </div>)}
      </div>)}
    </div>

    {/* FAB */}
    <button style={{position:"absolute",bottom:92,right:16,width:48,height:48,borderRadius:14,background:C.primary,border:"none",cursor:"pointer",boxShadow:"0 4px 16px rgba(79,70,229,.3)",display:"flex",alignItems:"center",justifyContent:"center",zIndex:40}}>
      {I.plus("#fff",20)}
    </button>
  </div>;
};

/* ══ Recreation ══ */
const RecScr = () => {
  const [step,setStep]=useState(0);
  useEffect(()=>{if(step===1){const t=setTimeout(()=>setStep(2),2000);return()=>clearTimeout(t)}},[step]);

  if(step===0) return <div style={{height:"100%",background:C.bg}}>
    <SB/>
    <div style={{padding:"8px 16px 0",background:C.white,borderBottom:`0.5px solid ${C.line}`}}>
      <h1 style={{fontSize:18,fontWeight:700,color:C.ink,margin:"0 0 14px"}}>룩 재현</h1>
    </div>
    {/* Upload — clean card */}
    <div style={{padding:"12px 16px 0"}}>
      <div onClick={()=>setStep(1)} style={{background:C.white,borderRadius:14,height:200,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",gap:10,cursor:"pointer",boxShadow:C.card}}>
        <div style={{width:48,height:48,borderRadius:24,background:C.bg,display:"flex",alignItems:"center",justifyContent:"center"}}>
          {I.cam(C.ter,26)}
        </div>
        <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:0}}>사진 선택하기</p>
        <p style={{fontSize:13,color:C.ter,margin:0}}>갤러리에서 고르거나 직접 찍어주세요</p>
      </div>
    </div>
    {/* Recent — vertical list with 더보기 */}
    <div style={{padding:"16px 16px 0"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10}}>
        <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:0}}>최근 분석</p>
        <span style={{fontSize:13,color:C.ter,cursor:"pointer"}}>더보기</span>
      </div>
      <div style={{background:C.white,borderRadius:12,overflow:"hidden",boxShadow:C.card}}>
        {RECENT.slice(0,3).map((r,i)=><div key={r.id} style={{display:"flex",alignItems:"center",gap:12,padding:"12px 14px",borderBottom:i<2?`0.5px solid ${C.line}`:"none"}}>
          <div style={{width:44,height:44,borderRadius:8,background:r.color,flexShrink:0}}/>
          <div style={{flex:1}}>
            <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>{r.label}</p>
            <p style={{fontSize:12,color:C.ter,margin:0}}>매칭 완료</p>
          </div>
          <span style={{fontSize:14,fontWeight:700,color:C.primary}}>{r.score}%</span>
        </div>)}
      </div>
    </div>
    {/* Count */}
    <div style={{display:"flex",justifyContent:"center",marginTop:18}}>
      <span style={{fontSize:12,color:C.ter}}>이번 달 남은 횟수 <span style={{fontWeight:600,color:C.primary}}>3/5</span></span>
    </div>
  </div>;

  if(step===1) return <div style={{height:"100%",background:C.white,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center"}}>
    <div style={{width:40,height:40,borderRadius:20,border:`2px solid ${C.line}`,borderTopColor:C.primary,animation:"sp .7s linear infinite",marginBottom:20}}/>
    <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:"0 0 4px"}}>AI가 분석 중이에요</p>
    <p style={{fontSize:13,color:C.ter,margin:0,textAlign:"center",lineHeight:1.5}}>코디를 식별하고 내 옷장과<br/>매칭하고 있어요</p>
    <style>{`@keyframes sp{to{transform:rotate(360deg)}}`}</style>
  </div>;

  /* Results — Toss card + Instagram action bar */
  const matched=[{name:"크림 니트",score:95,cat:"상의",color:"#E8D5B7"},{name:"블랙 슬랙스",score:88,cat:"하의",color:"#1A1A2E"},{name:"브라운 로퍼",score:78,cat:"신발",color:"#8B4513"}];
  return <div style={{height:"100%",background:C.bg,overflowY:"auto"}}>
    <div style={{background:C.white}}>
      <SB/>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 16px 0"}}>
        <button onClick={()=>setStep(0)} style={{background:"none",border:"none",cursor:"pointer",padding:0}}>{I.back()}</button>
        <span style={{fontSize:15,fontWeight:600,color:C.ink}}>분석 결과</span>
        <button style={{background:"none",border:"none",cursor:"pointer",padding:0}}>{I.share()}</button>
      </div>
      {/* Score — big centered */}
      <div style={{textAlign:"center",padding:"20px 0 24px"}}>
        <p style={{fontSize:12,color:C.ter,margin:"0 0 6px",fontWeight:500}}>매칭 점수</p>
        <span style={{fontSize:48,fontWeight:800,color:C.primary,letterSpacing:-2}}>87<span style={{fontSize:18,fontWeight:600,color:C.ter}}>%</span></span>
      </div>
      {/* Instagram-like action bar */}
      <div style={{display:"flex",padding:"0 16px 16px",gap:10}}>
        <button style={{flex:1,padding:"11px",background:C.primary,border:"none",borderRadius:8,fontSize:13,fontWeight:600,color:"#fff",cursor:"pointer"}}>코디 저장</button>
        <button style={{flex:1,padding:"11px",background:C.bg,border:`1px solid ${C.lineDark}`,borderRadius:8,fontSize:13,fontWeight:600,color:C.ink,cursor:"pointer"}}>공유하기</button>
      </div>
    </div>
    <div style={{padding:"8px 16px 100px"}}>
      <p style={{fontSize:13,fontWeight:600,color:C.sec,margin:"4px 0 8px"}}>매칭된 아이템 {matched.length}</p>
      <div style={{background:C.white,borderRadius:12,overflow:"hidden",boxShadow:C.card}}>
        {matched.map((m,i)=><div key={i} style={{display:"flex",alignItems:"center",gap:12,padding:"12px 14px",borderBottom:i<matched.length-1?`0.5px solid ${C.line}`:"none"}}>
          <div style={{width:40,height:40,borderRadius:8,background:m.color,flexShrink:0}}/>
          <div style={{flex:1}}>
            <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>{m.name}</p>
            <p style={{fontSize:12,color:C.ter,margin:0}}>{m.cat}</p>
          </div>
          <span style={{fontSize:13,fontWeight:700,color:C.primary}}>{m.score}%</span>
        </div>)}
      </div>
      <p style={{fontSize:13,fontWeight:600,color:C.sec,margin:"14px 0 8px"}}>빠진 아이템 1</p>
      <div style={{background:C.white,borderRadius:12,padding:"12px 14px",boxShadow:C.card,display:"flex",alignItems:"center",gap:12}}>
        <div style={{width:40,height:40,borderRadius:8,background:C.bg,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C.mute} strokeWidth="1.5"><path d="M12 6a2 2 0 002-2c0-1-1-2-2-2s-2 1-2 2"/><path d="M12 6L4 16h16L12 6z"/></svg>
        </div>
        <div style={{flex:1}}>
          <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>베이지 머플러</p>
          <p style={{fontSize:12,color:C.ter,margin:0}}>액세서리</p>
        </div>
        <button style={{background:C.ink,border:"none",borderRadius:6,padding:"7px 12px",cursor:"pointer",display:"flex",alignItems:"center",gap:4}}>
          <span style={{fontSize:12,fontWeight:600,color:"#fff"}}>쇼핑</span>{I.ext()}
        </button>
      </div>
    </div>
  </div>;
};

/* ══ Daily ══ */
const DailyScr = () => {
  const days=["일","월","화","수","목","금","토"];
  const today=4;
  return <div style={{height:"100%",background:C.bg}}>
    <SB/>
    <div style={{background:C.white,borderBottom:`0.5px solid ${C.line}`,padding:"8px 16px 14px"}}>
      <h1 style={{fontSize:18,fontWeight:700,color:C.ink,margin:"0 0 14px"}}>데일리 코디</h1>
      <div style={{display:"flex",justifyContent:"space-between"}}>
        {days.map((d,i)=>{
          const act=i===today, past=i<today;
          return <div key={d} style={{textAlign:"center",width:36}}>
            <p style={{fontSize:11,color:act?C.primary:C.ter,margin:"0 0 6px",fontWeight:500}}>{d}</p>
            <div style={{width:32,height:32,borderRadius:16,margin:"0 auto",
              background:act?C.primary:"transparent",
              border:past?`1.5px solid ${C.lineDark}`:act?"none":`1.5px solid ${C.line}`,
              display:"flex",alignItems:"center",justifyContent:"center"}}>
              <span style={{fontSize:12,fontWeight:act?700:500,color:act?"#fff":past?C.ink:C.mute}}>{22+i}</span>
            </div>
            {past&&<div style={{width:3,height:3,borderRadius:1.5,background:C.primary,margin:"4px auto 0",opacity:.4}}/>}
          </div>;
        })}
      </div>
    </div>
    <div style={{padding:"10px 16px"}}>
      <div style={{background:C.white,borderRadius:14,padding:16,boxShadow:C.card}}>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
          <div><p style={{fontSize:14,fontWeight:700,color:C.ink,margin:"0 0 2px"}}>오늘의 코디</p><p style={{fontSize:12,color:C.ter,margin:0}}>2월 26일 목요일</p></div>
        </div>
        <div style={{display:"flex",gap:6,marginBottom:12}}>
          {[{color:"#E8D5B7",name:"크림 니트"},{color:"#1A1A2E",name:"블랙 슬랙스"},{color:"#8B4513",name:"브라운 로퍼"}].map((m,i)=><div key={i} style={{flex:1}}>
            <div style={{height:88,background:m.color,borderRadius:8,marginBottom:5}}/>
            <p style={{fontSize:11,color:C.ter,margin:0,textAlign:"center"}}>{m.name}</p>
          </div>)}
        </div>
        <div style={{display:"flex",gap:4}}>
          <span style={{background:C.bg,borderRadius:4,padding:"3px 8px",fontSize:11,color:C.sec}}>미니멀</span>
          <span style={{background:C.bg,borderRadius:4,padding:"3px 8px",fontSize:11,color:C.sec}}>가을코디</span>
        </div>
      </div>
      <div style={{background:C.primary,borderRadius:12,padding:"14px 16px",marginTop:8,display:"flex",alignItems:"center",gap:12}}>
        {I.lock("#fff")}
        <div style={{flex:1}}>
          <p style={{fontSize:13,fontWeight:600,color:"#fff",margin:"0 0 2px"}}>데일리 코디는 프리미엄 기능이에요</p>
          <p style={{fontSize:11,color:"rgba(255,255,255,.55)",margin:0}}>7일 무료 체험 시작하기</p>
        </div>
        {I.right("#fff")}
      </div>
    </div>
  </div>;
};

/* ══ Profile ══ */
const ProfileScr = () => <div style={{height:"100%",background:C.bg}}>
  <SB/>
  <div style={{background:C.white,padding:"8px 16px 18px",borderBottom:`0.5px solid ${C.line}`}}>
    <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:16}}>
      <div style={{width:44,height:44,borderRadius:22,background:C.bg,display:"flex",alignItems:"center",justifyContent:"center"}}>
        <span style={{fontSize:18,fontWeight:700,color:C.primary,fontFamily:"Georgia,serif"}}>R</span>
      </div>
      <div>
        <p style={{fontSize:16,fontWeight:700,color:C.ink,margin:"0 0 1px"}}>사용자</p>
        <span style={{fontSize:12,color:C.ter}}>무료 플랜</span>
      </div>
    </div>
    <div style={{display:"flex",background:C.bg,borderRadius:10,padding:"12px 0"}}>
      {[{n:"8",l:"내 옷"},{n:"7",l:"룩 재현"},{n:"3",l:"데일리"}].map((s,i)=><div key={i} style={{flex:1,textAlign:"center",borderRight:i<2?`1px solid ${C.lineDark}`:"none"}}>
        <p style={{fontSize:18,fontWeight:700,color:C.ink,margin:"0 0 1px"}}>{s.n}</p>
        <p style={{fontSize:11,color:C.ter,margin:0}}>{s.l}</p>
      </div>)}
    </div>
  </div>
  <div style={{padding:"10px 16px"}}>
    <div style={{background:C.primary,borderRadius:12,padding:"14px 16px",marginBottom:10,display:"flex",alignItems:"center",justifyContent:"space-between"}}>
      <div>
        <p style={{fontSize:13,fontWeight:700,color:"#fff",margin:"0 0 2px"}}>프리미엄으로 업그레이드</p>
        <p style={{fontSize:11,color:"rgba(255,255,255,.55)",margin:0}}>옷장 무제한 · 재현 무제한 · 데일리 코디</p>
      </div>
      <div style={{background:"#fff",borderRadius:6,padding:"5px 10px",flexShrink:0}}>
        <span style={{fontSize:12,fontWeight:700,color:C.primary}}>₩4,900</span>
      </div>
    </div>
    <div style={{background:C.white,borderRadius:12,overflow:"hidden",boxShadow:C.card}}>
      {["알림 설정","자주 묻는 질문","문의하기","이용약관","개인정보처리방침","앱 버전 1.0.0"].map((l,i,a)=>
        <div key={i} style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"14px 16px",borderBottom:i<a.length-1?`0.5px solid ${C.line}`:"none",cursor:"pointer"}}>
          <span style={{fontSize:14,color:i===a.length-1?C.ter:C.ink}}>{l}</span>
          {i<a.length-1&&I.right()}
        </div>
      )}
    </div>
  </div>
</div>;

/* ══ TabBar ══ */
const Tab = ({active,onChange}) => {
  const tabs=[
    {id:"wardrobe",l:"옷장",ic:I.grid,icA:I.gridFill},
    {id:"rec",l:"룩 재현",ic:I.scan,icA:I.scanFill},
    {id:"daily",l:"데일리",ic:I.cal,icA:I.calFill},
    {id:"profile",l:"마이",ic:I.user,icA:I.userFill},
  ];
  return <div style={{position:"absolute",bottom:0,left:0,right:0,background:"rgba(255,255,255,.97)",backdropFilter:"blur(20px)",WebkitBackdropFilter:"blur(20px)",borderTop:`0.5px solid ${C.line}`,display:"flex",justifyContent:"space-around",padding:"6px 0 28px",zIndex:50}}>
    {tabs.map(t=><button key={t.id} onClick={()=>onChange(t.id)} style={{background:"none",border:"none",cursor:"pointer",display:"flex",flexDirection:"column",alignItems:"center",gap:3,padding:0,minWidth:48}}>
      {active===t.id?t.icA(C.primary):t.ic(C.mute)}
      <span style={{fontSize:10,fontWeight:active===t.id?600:400,color:active===t.id?C.primary:C.mute}}>{t.l}</span>
    </button>)}
  </div>;
};

/* ══ App ══ */
export default function App(){
  const [scr,setScr]=useState("splash");
  const [tab,setTab]=useState("wardrobe");
  const wrap=(ch)=><div style={{minHeight:"100vh",background:"#E5E2DD",display:"flex",alignItems:"center",justifyContent:"center",padding:20}}>{ch}</div>;

  if(scr==="splash") return wrap(<Splash onDone={()=>setScr("onboarding")}/>);
  if(scr==="onboarding") return wrap(<Onboarding onDone={()=>setScr("login")}/>);
  if(scr==="login") return wrap(<Login onLogin={()=>setScr("main")}/>);

  return wrap(
    <div style={ph}>
      {tab==="wardrobe"&&<WardrobeScr/>}
      {tab==="rec"&&<RecScr/>}
      {tab==="daily"&&<DailyScr/>}
      {tab==="profile"&&<ProfileScr/>}
      <Tab active={tab} onChange={setTab}/>
    </div>
  );
}
