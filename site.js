/* KernelScope X portfolio-style homepage: all process/metric data here are illustrative.
   Browser interactions never read host OS data, kill processes, or contact an API. */
(() => {
  "use strict";
  const root = document.documentElement;
  const $ = (id) => document.getElementById(id);
  const safeGet = (key) => { try { return localStorage.getItem(key); } catch { return null; } };
  const safeSet = (key, value) => { try { localStorage.setItem(key, value); } catch { /* optional */ } };
  const motionEnabled = false; // Do not animate or rotate interface automatically.
  let theme = safeGet("ksx-theme") === "light" ? "light" : "dark";
  const themeButton = $("theme-toggle");
  function applyTheme() {
    root.dataset.theme = theme;
    root.dataset.motion = "off";
    themeButton.textContent = theme === "dark" ? "◐ Light" : "◑ Dark";
    themeButton.setAttribute("aria-pressed", String(theme === "light"));
    document.querySelector('meta[name="theme-color"]').setAttribute("content", theme === "dark" ? "#090a0e" : "#f2f0ed");
  }
  applyTheme();
  themeButton.addEventListener("click", () => {
    theme = theme === "dark" ? "light" : "dark";
    safeSet("ksx-theme", theme);
    applyTheme();
  });

  // Sticky navigation and mobile menu
  const menuToggle = $("menu-toggle"), mobileNav = $("mobile-nav");
  function closeMenu() { mobileNav.hidden = true; menuToggle.setAttribute("aria-expanded","false"); menuToggle.textContent = "Menu +"; }
  menuToggle.addEventListener("click", () => {
    const opening = mobileNav.hidden;
    mobileNav.hidden = !opening;
    menuToggle.setAttribute("aria-expanded",String(opening));
    menuToggle.textContent = opening ? "Close ×" : "Menu +";
  });
  mobileNav.querySelectorAll("a").forEach(a => a.addEventListener("click", closeMenu));

  const progress = $("progress-line");
  let frameScheduled = false;
  function updateScroll() {
    const max = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
    progress.style.width = (100 * window.scrollY / max).toFixed(2) + "%";
    frameScheduled = false;
  }
  window.addEventListener("scroll", () => { if (!frameScheduled) { frameScheduled = true; requestAnimationFrame(updateScroll); } }, {passive:true});
  window.addEventListener("resize", updateScroll);updateScroll();
  const io = ("IntersectionObserver" in window) ? new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add("in-view"); io.unobserve(e.target); } });
  }, {threshold: .12, rootMargin:"0px 0px -15px 0px"}) : null;
  document.querySelectorAll(".reveal").forEach(e => { if (!io || !motionEnabled) e.classList.add("in-view"); else io.observe(e); });
  const sections = ["overview", "workspace", "modules", "laboratory", "console"].map($).filter(Boolean);
  const spy = "IntersectionObserver" in window ? new IntersectionObserver(entries => {
    entries.forEach(entry => { if (!entry.isIntersecting) return; document.querySelectorAll(".desktop-nav a").forEach(a => a.setAttribute("aria-current",String(a.getAttribute("href") === "#"+entry.target.id))); });
  }, {rootMargin:"-12% 0px -72% 0px"}) : null;
  if (spy) sections.forEach(section=>spy.observe(section));

  // Hero: clearly labeled simulated data, switchable CPU/memory/thread chart
  const metricButtons = [...document.querySelectorAll(".monitor-card")];
  const chartTitle = $("chart-selected"), chartLine = $("trace-line"), chartArea = $("trace-area");
  let activeMetric = "cpu";
  const sequences = {
    cpu: [18,24,22,30,25,21,26,36,29,32,28,37,23,21,24,19,30,35,26,32],
    memory: [39,39.4,39.1,40,40.5,40.3,41,40.6,41.2,41,41.6,41.2,42,41.3,41.7,41.5,41.8,42,41.8,42.4],
    threads: [41,43,42,48,46,47,49,51,48,50,53,51,53,52,51,54,57,52,55,54]
  };
  function drawTrace() {
    const seq = sequences[activeMetric];
    const points = seq.map((v,i) => (8 + i*504/(seq.length-1)).toFixed(1)+","+(113-v).toFixed(1)).join(" ");
    const area = "M"+points.split(" ").join(" L")+" L512,119 L8,119 Z";
    chartLine.setAttribute("points",points);
    chartArea.setAttribute("d",area);
    chartTitle.textContent = {cpu:"CPU · utilization",memory:"RAM · utilization",threads:"Threads · normalized index"}[activeMetric];
    chartLine.style.stroke = activeMetric === "memory" ? "var(--violet)" : activeMetric === "threads" ? "var(--teal)" : "var(--red)";
  }
  function selectMetric(metric){
    if (!sequences[metric]) return;
    activeMetric=metric;
    metricButtons.forEach(b=>b.setAttribute("aria-pressed",String(b.dataset.metric===metric)));
    drawTrace();
  }
  metricButtons.forEach(b=>b.addEventListener("click",()=>selectMetric(b.dataset.metric)));
  drawTrace();
  // Static chart; selection updates on click, without continuous motion.

  // Process DNA mini-map is a keyboard-accessible, fictional graph
  const nodes={
    system:{name:"System.exe",pid:"0004",parent:"—",threads:"64",memory:"Access restricted",cpu:"0.1%",status:"Protected system root",desc:"A representation of the OS root process. Windows protects real system processes from ordinary user actions."},
    shell:{name:"explorer.exe",pid:"1288",parent:"0004",threads:"42",memory:"312 MiB",cpu:"1.8%",status:"User interface",desc:"The desktop shell. In this fictional process map it is a parent of other user-facing applications."},
    studio:{name:"KernelScopeX.exe",pid:"9042",parent:"1288",threads:"15",memory:"185 MiB",cpu:"2.4%",status:"Monitoring",desc:"The native Qt monitor, designed to collect system snapshots on a background thread."},
    browser:{name:"browser.exe",pid:"6620",parent:"1288",threads:"34",memory:"624 MiB",cpu:"6.2%",status:"Application",desc:"A sample multi-threaded application. Resource figures on this website are demonstrative only."},
    lab:{name:"scheduler-demo.exe",pid:"8124",parent:"9042",threads:"4",memory:"78 MiB",cpu:"0.9%",status:"Sample workload",desc:"A fictional scheduler experiment, separate from real Windows process scheduling."}
  };
  const nodeButtons=[...document.querySelectorAll(".node[data-node]")];
  function inspectNode(key) {
    const p=nodes[key];if(!p)return;
    nodeButtons.forEach(b=>{const on=b.dataset.node===key;b.classList.toggle("active",on);b.setAttribute("aria-pressed",String(on));});
    document.querySelectorAll(".map-line path").forEach(path=>path.classList.toggle("active",path.dataset.to===key));
    for (const [id,value] of [["process-name",p.name],["process-desc",p.desc],["process-pid",p.pid],["process-parent",p.parent],["process-threads",p.threads],["process-memory",p.memory],["process-cpu",p.cpu],["process-status",p.status]]) $(id).textContent=value;
  }
  nodeButtons.forEach(btn=>btn.addEventListener("click",()=>inspectNode(btn.dataset.node)));
  inspectNode("studio");

  // Accurate preset scheduling demonstration; actual interactive editor lives in demo.html
  const workload=[{name:"P1",arrival:0,burst:8},{name:"P2",arrival:1,burst:4},{name:"P3",arrival:2,burst:9},{name:"P4",arrival:3,burst:5}];
  function schedule(mode,q=3) {
    const jobs=workload.map((p,i)=>({...p,i,left:p.burst,start:-1,done:-1})),
      arrivalOrder=[...jobs].sort((a,b)=>a.arrival-b.arrival||a.i-b.i),segments=[];
    let time=0,finished=0;
    const block=(name,start,end)=>{if(end<=start)return;const prev=segments[segments.length-1];if(prev&&prev.name===name&&prev.end===start){prev.end=end;}else segments.push({name,start,end});};
    const run=(p,units)=>{if(p.start===-1)p.start=time;block(p.name,time,time+units);time+=units;p.left-=units;if(!p.left){p.done=time;finished++;}};
    if (mode==="rr") {
      let next=0,queue=[];
      while(finished<jobs.length){
        while(next<arrivalOrder.length && arrivalOrder[next].arrival<=time) queue.push(arrivalOrder[next++]);
        if(!queue.length){const t=arrivalOrder[next].arrival;block("Idle",time,t);time=t;continue;}
        const p=queue.shift();run(p,Math.min(q,p.left));
        while(next<arrivalOrder.length && arrivalOrder[next].arrival<=time) queue.push(arrivalOrder[next++]);
        if(p.left)queue.push(p);
      }
    } else {
      while(finished<jobs.length){
        let ready=arrivalOrder.filter(p=>p.left&&p.arrival<=time);
        if(!ready.length){const p=arrivalOrder.find(p=>p.left);block("Idle",time,p.arrival);time=p.arrival;continue;}
        if(mode==="sjf")ready.sort((a,b)=>a.burst-b.burst||a.arrival-b.arrival||a.i-b.i);
        run(ready[0],ready[0].left);
      }
    }
    return {segments,total:time,wait:jobs.reduce((s,p)=>s+p.done-p.arrival-p.burst,0)/jobs.length,turn:jobs.reduce((s,p)=>s+p.done-p.arrival,0)/jobs.length,response:jobs.reduce((s,p)=>s+p.start-p.arrival,0)/jobs.length};
  }
  const algoButtons=[...document.querySelectorAll("[data-algorithm]")];
  function selectAlgorithm(mode) {
    const result=schedule(mode),g=$("gantt-mini");
    algoButtons.forEach(b=>b.setAttribute("aria-pressed",String(b.dataset.algorithm===mode)));
    g.replaceChildren();
    const colors=["var(--red)","var(--violet)","var(--teal)","var(--red)"];
    result.segments.forEach(seg=>{
      const bar=document.createElement("div");bar.style.flex=String(seg.end-seg.start)+" 1 0";
      if(seg.name==="Idle")bar.className="idle";
      else {const i=workload.findIndex(p=>p.name===seg.name);bar.style.background=colors[i];bar.style.color=i===1||i===2?"#0f1320":"#fff";}
      bar.title=seg.name+": "+seg.start+" → "+seg.end;
      if(result.segments.length<=12){const l=document.createElement("span");l.textContent=seg.name;bar.append(l);const small=document.createElement("small");small.textContent=String(seg.end-seg.start)+"t";bar.append(small)}
      g.append(bar);
    });
    $("lab-wait").textContent=result.wait.toFixed(2);
    $("lab-turn").textContent=result.turn.toFixed(2);
    $("lab-response").textContent=result.response.toFixed(2);
    $("lab-finish").textContent=String(result.total);
    $("lab-name").textContent={fcfs:"First Come First Served",sjf:"Shortest Job First",rr:"Round Robin · q=3"}[mode];
  }
  algoButtons.forEach(b=>b.addEventListener("click",()=>selectAlgorithm(b.dataset.algorithm)));
  selectAlgorithm("fcfs");

  // Tiny explainable, safe, local browser terminal.
  const windowEl=$("terminal-window"),form=$("terminal-form"),input=$("terminal-input");
  const guide=[
    ["help", "Available: help · about · processes · inspect · schedule · memory · source · demo · clear · status"],
    ["about", "KernelScope X is a native Windows C++20/Qt 6 process monitoring and education project."],
    ["processes", "Sample process map: System.exe → explorer.exe → KernelScopeX.exe / browser.exe → scheduler-demo.exe"],
    ["inspect", "Click a node in Process DNA to inspect fictional PID/PPID, threads, and memory."],
    ["schedule", "The OS Lab preview demonstrates FCFS, SJF and Round Robin with reproducible sample workloads."],
    ["memory", "Explore interactive paging, TLB cache and memory-fit algorithms at memory-lab.html."],
    ["source", "Project source: github.com/sudip09-sys/KernelScope-X"],
    ["demo", "Open demo.html for the full interactive browser simulation."],
    ["status", "Website: static. Native monitoring: Windows app only. Browser cannot inspect your running processes."],
    ["sudo", "Permission denied — and that's by design. The web demo never runs privileged commands."]
  ];
  function line(kind,value){const p=document.createElement("p");p.className=kind;const text=document.createTextNode(value);p.append(text);windowEl.append(p);windowEl.scrollTop=windowEl.scrollHeight;}
  function command(raw){
    const val=raw.trim();if(!val)return;
    line("user","> "+val);
    const key=val.toLowerCase().split(/\s+/)[0];
    if(key==="clear"){windowEl.replaceChildren();return;}
    if(key==="theme"){theme=theme==="dark"?"light":"dark";safeSet("ksx-theme",theme);applyPreferences();line("response","Switched to "+theme+" theme.");return;}
    if(key==="time"){line("response",new Date().toLocaleString());return;}
    const found=guide.find(x=>x[0]===key);
    if(found)line("response",found[1]);else line("response","Unknown command. Try 'help'.");
  }
  form.addEventListener("submit",e=>{e.preventDefault();command(input.value);input.value="";input.focus()});
  line("response","KernelScope X / browser console v1. Type 'help' to begin.");

  // Command palette (Ctrl/Cmd+K)
  const palette=$("palette"),paletteInput=$("palette-input"),paletteResults=$("palette-results");
  const actions=[
    {label:"View interactive system map",target:"#workspace",keys:"map process inspector"},
    {label:"Explore native modules",target:"#modules",keys:"modules features"},
    {label:"Run scheduling comparison",target:"#laboratory",keys:"lab cpu scheduling"},
    {label:"Open Memory Intelligence Lab",target:"memory-lab.html",keys:"paging memory allocation TLB First Fit Best Fit Worst Fit"},
    {label:"Open full browser demo",target:"demo.html#demo",keys:"browser interactive simulator"},
    {label:"Go to command console",target:"#console",keys:"terminal command"},
    {label:"View project on GitHub",target:"https://github.com/sudip09-sys/KernelScope-X",keys:"github source repository"}
  ];
  function go(target){closePalette();if(target.startsWith("#")){const el=document.querySelector(target);el?.scrollIntoView({behavior:motionEnabled?"smooth":"auto"})}else{window.location.href=target}}
  function populate(q=""){
    paletteResults.replaceChildren();const matches=actions.filter(a=>(a.label+" "+a.keys).toLowerCase().includes(q.toLowerCase())).slice(0,6);
    for(const a of matches){const b=document.createElement("button");b.type="button";b.textContent="↗  "+a.label;b.addEventListener("click",()=>go(a.target));paletteResults.append(b)}
    if(!matches.length){const p=document.createElement("p");p.className="palette-help";p.textContent="No matching actions.";paletteResults.append(p)}
  }
  function openPalette(){palette.hidden=false;populate();paletteInput.value="";paletteInput.focus()}
  function closePalette(){palette.hidden=true;paletteInput.value=""}
  $("palette-open").addEventListener("click",openPalette);
  $("palette-close").addEventListener("click",closePalette);
  palette.addEventListener("click",e=>{if(e.target===palette)closePalette()});
  paletteInput.addEventListener("input",()=>populate(paletteInput.value));
  paletteInput.addEventListener("keydown",e=>{if(e.key==="Enter"){const b=paletteResults.querySelector("button");if(b){e.preventDefault();b.click()}}});
  document.addEventListener("keydown",e=>{
    if((e.metaKey||e.ctrlKey)&&e.key.toLowerCase()==="k"){e.preventDefault();if(palette.hidden)openPalette();else closePalette();}
    if(e.key==="Escape"){if(!palette.hidden)closePalette();else if(!mobileNav.hidden)closeMenu();}
  });
  // If the command palette overlays active controls, keep keyboard focus in it.
  palette.addEventListener("keydown",e=>{
    if(e.key!=="Tab")return;
    const focusables=[...palette.querySelectorAll("button:not([disabled]),input:not([disabled])")].filter(x=>x.offsetParent!==null);
    if(!focusables.length)return;
    const first=focusables[0],last=focusables[focusables.length-1];
    if(e.shiftKey&&document.activeElement===first){e.preventDefault();last.focus()}
    else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first.focus()}
  });
  $("copy-link").addEventListener("click",async()=>{
    const url="https://github.com/sudip09-sys/KernelScope-X";
    try{await navigator.clipboard.writeText(url);showToast("GitHub link copied.");}
    catch{showToast("Repo: github.com/sudip09-sys/KernelScope-X");}
  });
  let toastTimeout;
  function showToast(message){const toast=$("toast");toast.textContent=message;toast.hidden=false;clearTimeout(toastTimeout);toastTimeout=setTimeout(()=>toast.hidden=true,3200)}
  $("year").textContent=new Date().getFullYear();
})();
