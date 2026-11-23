(() => {
"use strict";
const $=id=>document.getElementById(id);
const pageSize=1024, mapping=new Map([[0,5],[1,9],[2,1],[3,12]]);
const colors=["#f34c61","#9b95ed","#58dfbf","#f8b57a","#79b8eb","#e59cce","#acc782","#caa5f6","#e8b9b2","#99d4bc"];
let tlb=[],hits=0,misses=0,state=null;
function node(tag,value,className){const x=document.createElement(tag);x.textContent=String(value);if(className)x.className=className;return x;}
function pageRows(selected){
 const body=$("page-table-rows");body.replaceChildren();
 for(const [page,frame] of mapping){const row=node("tr","",page===selected?"highlight":"");row.append(node("td","Page "+page),node("td","Frame "+frame));body.append(row);}
}
function frames(active){
 const box=$("frame-map");box.replaceChildren();const inverse=new Map([...mapping].map(pair=>[pair[1],pair[0]]));
 for(let i=0;i<=12;i++){const occupied=inverse.has(i);const e=node("div","","frame"+(occupied?" occupied":"")+(i===active?" active":""));e.append(node("small","FRAME "+i),node("strong",occupied?"P"+inverse.get(i):"FREE"));e.title=occupied?"Frame "+i+" contains logical page "+inverse.get(i):"Unmapped example frame";box.append(e);}
}
function drawTlb(){
 const box=$("tlb-slots");box.replaceChildren();
 for(let i=0;i<3;i++){const e=node("div","","tlb-slot"),entry=tlb[i];e.append(node("span",i===0?"MOST RECENT":"SLOT "+(i+1)),node("b",entry?"P"+entry.page+" → F"+entry.frame:"EMPTY"));box.append(e);}
 $("tlb-hits").textContent=hits;$("tlb-misses").textContent=misses;$("tlb-rate").textContent=(hits+misses?100*hits/(hits+misses):0).toFixed(0)+"%";
}
function log(address,outcome,physical){
 const e=node("div","","log-row");e.append(node("span","LOGICAL "+address),node("span",outcome+(physical===null?"":" → "+physical),outcome==="TLB HIT"?"hit":outcome==="INVALID"?"fault-text":"miss"));
 const parent=$("translation-log");parent.prepend(e);while(parent.children.length>16)parent.lastElementChild.remove();
}
function translate(raw){
 const value=Number(raw);
 if(!Number.isSafeInteger(value)||value<0||value>1000000){
   $("paging-state").textContent="INVALID INPUT";$("paging-result").className="result fault";
   $("value-logical").textContent=String(raw).slice(0,25);
   for(const id of ["value-page","value-offset","value-frame","value-physical"])$(id).textContent="—";
   $("paging-explanation").textContent="Enter a non-negative whole-number logical address from 0 to 1,000,000.";
   pageRows(-1);frames(-1);return;
 }
 const page=Math.floor(value/pageSize),offset=value%pageSize,frame=mapping.get(page);
 $("value-logical").textContent=value;$("value-page").textContent=page;$("value-offset").textContent=offset;
 pageRows(page);
 document.querySelectorAll("[data-address]").forEach(button=>button.classList.toggle("selected",Number(button.dataset.address)===value));
 if(frame===undefined){
   misses++;$("value-frame").textContent="—";$("value-physical").textContent="FAULT";
   $("paging-result").className="result fault";$("paging-state").textContent="UNMAPPED PAGE";
   $("paging-explanation").textContent="Page "+page+" has no valid entry. Offset "+offset+" cannot be translated in this example.";
   frames(-1);drawTlb();log(value,"INVALID",null);return;
 }
 const where=tlb.findIndex(entry=>entry.page===page);
 let event="TLB MISS";
 if(where>=0){tlb.unshift(tlb.splice(where,1)[0]);hits++;event="TLB HIT";}
 else{tlb.unshift({page,frame});if(tlb.length>3)tlb.pop();misses++;}
 const physical=frame*pageSize+offset;
 $("value-frame").textContent=frame;$("value-physical").textContent=physical;
 $("paging-result").className="result success";$("paging-state").textContent=event;
 $("paging-explanation").textContent="Page "+page+" → Frame "+frame+". Physical = "+frame+" × 1024 + "+offset+" = "+physical+". The offset does not change.";
 frames(frame);drawTlb();log(value,event,physical);
}
$("translate").addEventListener("click",()=>translate($("logical").value));
$("logical").addEventListener("keydown",event=>{if(event.key==="Enter")translate($("logical").value)});
document.querySelectorAll("[data-address]").forEach(b=>b.addEventListener("click",()=>{$("logical").value=b.dataset.address;translate(b.dataset.address)}));
$("reset-tlb").addEventListener("click",()=>{tlb=[];hits=0;misses=0;$("translation-log").replaceChildren();drawTlb();$("paging-state").textContent="CACHE CLEARED";});
$("run-trace").addEventListener("click",()=>{
 tlb=[];hits=0;misses=0;$("translation-log").replaceChildren();
 for(const address of [0,1024,2048,1024,0,3000,5000])translate(address);
 $("logical").value=5000;
});
drawTlb();translate(1500);

// Contiguous allocation: every strategy works from an independent copy of the initial holes.
function readSizes(raw,label){
 const parts=raw.split(",").map(x=>x.trim());
 if(parts.length<1||parts.length>10||parts.some(p=>!/^\d+$/.test(p)))throw Error(label+": enter 1–10 comma-separated positive integers.");
 const result=parts.map(Number);
 if(result.some(n=>!Number.isSafeInteger(n)||n<1||n>100000))throw Error(label+": each value must be from 1 to 100000 KB.");
 return result;
}
function createStrategy(name,holes){
 return {name,holes:holes.map((cap,index)=>({index,cap,free:cap,segments:[]})),steps:[]};
}
function reset(){
 try{
   const holes=readSizes($("holes").value,"Holes");
   const requests=readSizes($("requests").value,"Processes");
   state={holes,requests,step:0,strategies:["First Fit","Best Fit","Worst Fit"].map(name=>createStrategy(name,holes))};
   $("alloc-status").classList.remove("error");
   $("alloc-status").textContent="Ready: "+requests.length+" process requests, "+holes.reduce((a,b)=>a+b,0)+" KB initially available.";
   render();
 }catch(err){$("alloc-status").classList.add("error");$("alloc-status").textContent=err.message;}
}
function pick(strategy,size){
 const candidates=strategy.holes.filter(h=>h.free>=size);
 if(!candidates.length)return null;
 if(strategy.name==="First Fit")return candidates[0];
 if(strategy.name==="Best Fit")return candidates.reduce((a,b)=>b.free<a.free?b:a);
 return candidates.reduce((a,b)=>b.free>a.free?b:a);
}
function step(){
 if(!state)return;
 if(state.step>=state.requests.length){$("alloc-status").textContent="All allocations attempted. Reset to run again.";return;}
 const size=state.requests[state.step],pid="P"+(state.step+1);
 for(const strategy of state.strategies){
   const hole=pick(strategy,size);
   if(hole){hole.segments.push({pid,size});hole.free-=size;}
   strategy.steps.push({pid,size,hole:hole?hole.index:-1,remaining:hole?hole.free:null});
 }
 state.step++;
 $("alloc-status").classList.remove("error");
 $("alloc-status").textContent=pid+" ("+size+" KB): "+state.strategies.map(s=>{
   const h=s.steps[s.steps.length-1].hole;
   return s.name+" → "+(h<0?"cannot place":"hole "+(h+1));
 }).join(" | ");
 render();
}
function runAll(){if(!state)return;while(state.step<state.requests.length)step();}
function drawStrategy(s){
 const card=node("article","","allocator-card");
 card.append(node("h3",s.name),node("p",s.name==="First Fit"?"The first available hole that fits.":s.name==="Best Fit"?"The smallest available hole that fits.":"The largest available hole that fits."));
 for(const h of s.holes){
   const item=node("div","","hole"),top=node("div","","hole-top"),bar=node("div","","hole-bar");
   top.append(node("span","HOLE "+(h.index+1)+" / "+h.cap+" KB"),node("span",h.free+" KB FREE"));
   for(const seg of h.segments){
     const el=node("div",seg.size/h.cap>.18?seg.pid:"","hole-seg");
     el.style.width=(100*seg.size/h.cap)+"%";el.style.background=colors[(Number(seg.pid.slice(1))-1)%colors.length];el.title=seg.pid+" occupies "+seg.size+" KB";bar.append(el);
   }
   if(h.free){const el=node("div",h.free/h.cap>.18?h.free+" free":"","hole-seg hole-free");el.style.width=(100*h.free/h.cap)+"%";el.title=h.free+" KB remaining";bar.append(el);}
   item.append(top,bar);card.append(item);
 }
 const placed=s.steps.filter(p=>p.hole>=0).length,free=s.holes.reduce((a,h)=>a+h.free,0),largest=Math.max(...s.holes.map(h=>h.free));
 const metrics=node("div","","alloc-metrics");
 for(const [label,value] of [["PLACED",placed+" / "+state.requests.length],["FREE KB",free],["LARGEST HOLE",largest],["OUTSIDE LARGEST",free-largest]]){
   const tile=node("div","");tile.append(node("small",label),node("b",value));metrics.append(tile);
 }
 card.append(metrics);const pills=node("div","","process-pills");
 for(const p of s.steps)pills.append(node("span",p.pid+": "+(p.hole<0?"FAILED":"H"+(p.hole+1)),p.hole<0?"unplaced":"placed"));
 card.append(pills);return card;
}
function render(){
 if(!state)return;
 $("alloc-step").disabled=$("alloc-all").disabled=state.step>=state.requests.length;
 const cards=$("allocator-grid");cards.replaceChildren();
 state.strategies.forEach(s=>cards.append(drawStrategy(s)));
 const body=$("alloc-rows");body.replaceChildren();
 for(let i=0;i<state.step;i++){
   const tr=node("tr","");
   tr.append(node("td","P"+(i+1)),node("td",state.requests[i]+" KB"));
   for(const s of state.strategies){
     const event=s.steps[i];
     tr.append(node("td",event.hole<0?"CANNOT PLACE":"H"+(event.hole+1)+" → "+event.remaining+" left",event.hole<0?"comparison-fail":"comparison-success"));
   }
   body.append(tr);
 }
 if(!state.step){const tr=node("tr",""),td=node("td","Click NEXT ALLOCATION to begin.");td.colSpan=5;tr.append(td);body.append(tr);}
}
$("alloc-reset").addEventListener("click",reset);
$("alloc-step").addEventListener("click",step);
$("alloc-all").addEventListener("click",runAll);
reset();

document.querySelectorAll(".reveal-answer").forEach(b=>b.addEventListener("click",()=>{
 const answer=b.nextElementSibling,show=answer.hidden;
 answer.hidden=!show;b.setAttribute("aria-expanded",String(show));
 b.textContent=show?"HIDE EXPLANATION":"REVEAL EXPLANATION";
}));
})();
