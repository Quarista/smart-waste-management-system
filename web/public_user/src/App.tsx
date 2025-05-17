import { useState } from "react";
import { SessionLoader } from "@/hooks/session-loader";
import { Link } from "react-router-dom";
import { Dialog, DialogPanel } from "@headlessui/react";
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";
import { RiGeminiFill } from "react-icons/ri";
import { Outlet } from "react-router-dom";

function App() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  return (
    <>
      <SessionLoader
        duration={3000}
        onLoadComplete={() => setIsLoading(false)}
      />
      <div className={isLoading ? "hidden" : ""}>
        <header className="bg-white/40 dark:bg-[#0A0A0A]/80 backdrop-blur-md fixed inset-x-0 top-0 z-50 text-black dark:text-white border-b border-zinc-300 dark:border-zinc-800">
          <nav
            aria-label="Global"
            className="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8"
          >
            <div className="flex lg:flex-1">
              <Link to="/" className="-m-1.5 p-1.5">
                <span className="sr-only">Waste Management System</span>
                <img
                  alt=""
                  src="https://i.ibb.co/rfGjqgLD/Logo-Ai-4-B-W.png"
                  className="h-auto w-8 md:w-12 dark:invert"
                />
              </Link>
            </div>
            <div className="flex lg:hidden">
              <button
                type="button"
                onClick={() => setMobileMenuOpen(true)}
                className="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
              >
                <span className="sr-only">Menu</span>
                <Bars3Icon aria-hidden="true" className="size-6" />
              </button>
            </div>
            <div className="hidden lg:flex lg:gap-x-6 bg-neutral-100/80 dark:bg-gray-500/20 p-3 rounded-3xl border-2 border-gray-300 dark:border-gray-200/10">
              <a href="/verified/portal/track">
                <span className="text-sm/6 font-medium text-gray-900 dark:text-gray-100 hover:bg-gray-600/10 dark:hover:bg-gray-300/10 duration-300 p-2 px-3 rounded-3xl">
                  Track
                </span>
              </a>
              <Link to="/explore">
                <span className="text-sm/6 font-medium text-gray-900 dark:text-gray-100 hover:bg-gray-600/10 dark:hover:bg-gray-300/10 duration-300 p-2 px-3 rounded-3xl">
                  Services
                </span>
              </Link>
              <Link to="/verified/portal/helpdesk">
                <span className="text-sm/6 font-medium text-gray-900 dark:text-gray-100 hover:bg-gray-600/10 dark:hover:bg-gray-300/10 duration-300 p-2 px-3 rounded-3xl">
                  Help
                </span>
              </Link>
              <Link to="/verified/updates">
                <span className="text-sm/6 font-medium text-gray-900 dark:text-gray-100 hover:bg-gray-600/10 dark:hover:bg-gray-300/10 duration-300 p-2 px-3 rounded-3xl">
                  Updates
                </span>
              </Link>
            </div>
            <div className="hidden lg:flex lg:flex-1 lg:justify-end">
              <Link
                to="verified/_active/chatbot"
                className="items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-transform duration-200 ring-offset-background  focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 group relative animate-rainbow cursor-pointer border-0 bg-[linear-gradient(#fff,#fff),linear-gradient(#fff_50%,rgba(255,255,255,0.6)_80%,rgba(0,0,0,0)),linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] bg-[length:200%] text-foreground [background-clip:padding-box,border-box,border-box] [background-origin:border-box] [border:calc(0.08*1rem)_solid_transparent] before:absolute before:bottom-[-20%] before:left-1/2 before:z-[0] before:h-[20%] before:w-[60%] before:-translate-x-1/2 before:animate-rainbow before:bg-[linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] before:[filter:blur(calc(0.8*1rem))] dark:bg-[linear-gradient(#121213,#121213),linear-gradient(#121213_50%,rgba(18,18,19,0.6)_80%,rgba(18,18,19,0)),linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] hover:scale-105 active:scale-95 h-10 px-4 py-2 inline-flex"
              >
                <div className="flex items-center">
                  <span className="text-lg text-purple-700 dark:text-purple-400 animate-pulse">
                    <RiGeminiFill />
                  </span>
                  <span className="ml-1 text-black dark:text-white lg:inline p-1">
                    AI Assistant
                  </span>
                </div>
              </Link>
            </div>
          </nav>
          <Dialog
            open={mobileMenuOpen}
            onClose={setMobileMenuOpen}
            className="lg:hidden"
          >
            <div className="fixed inset-0" />
            <DialogPanel className="fixed inset-y-0 right-0 z-50 w-full overflow-y-auto bg-white/90 dark:bg-[#0A0A0A]/80 backdrop-blur-md px-6 py-6 sm:max-w-sm sm:ring-1 sm:ring-gray-900/10">
              <div className="flex items-center justify-between">
                <Link to="/" className="-m-1.5 p-1.5">
                  <span className="sr-only">Waste Management System</span>
                  <img
                    alt=""
                    src="https://i.ibb.co/rfGjqgLD/Logo-Ai-4-B-W.png"
                    className="h-10 w-auto z-50 dark:invert"
                  />
                </Link>
                <button
                  type="button"
                  onClick={() => setMobileMenuOpen(false)}
                  className="-m-2.5 rounded-md p-2.5 text-gray-700"
                >
                  <span className="sr-only">Close</span>
                  <XMarkIcon aria-hidden="true" className="size-6" />
                </button>
              </div>
              <div className="mt-6 flow-root">
                <div className="-my-6 divide-y divide-gray-500/10">
                  <div className="space-y-2 py-6">
                    <a
                      href="/verified/portal/track"
                      className="-mx-3 block rounded-lg px-3 py-2 text-base/7 font-medium text-gray-900 hover:bg-gray-50 dark:text-gray-100 dark:hover:bg-gray-800/25 duration-300"
                    >
                      Track
                    </a>
                    <Link
                      to="/verified/updates"
                      className="-mx-3 block rounded-lg px-3 py-2 text-base/7 font-medium text-gray-900 hover:bg-gray-50 dark:text-gray-100 dark:hover:bg-gray-800/25 duration-300"
                    >
                      Updates
                    </Link>
                    <Link
                      to="/verified/portal/helpdesk"
                      className="-mx-3 block rounded-lg px-3 py-2 text-base/7 font-medium text-gray-900 hover:bg-gray-50 dark:text-gray-100 dark:hover:bg-gray-800/25 duration-300"
                    >
                      Help
                    </Link>
                    <Link
                      to="/explore"
                      className="-mx-3 block rounded-lg px-3 py-2 text-base/7 font-medium text-gray-900 hover:bg-gray-50 dark:text-gray-100 dark:hover:bg-gray-800/25 duration-300"
                    >
                      Services
                    </Link>
                  </div>
                  <div className="py-6">
                    <div className="-mx-3 block rounded-lg px-3 py-2.5 text-base/7 text-black dark:text-white">
                      <Link
                        to="verified/_active/chatbot"
                        className="items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-transform duration-200 ring-offset-background  focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 group relative animate-rainbow cursor-pointer border-0 bg-[linear-gradient(#fff,#fff),linear-gradient(#fff_50%,rgba(255,255,255,0.6)_80%,rgba(0,0,0,0)),linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] bg-[length:200%] text-foreground [background-clip:padding-box,border-box,border-box] [background-origin:border-box] [border:calc(0.08*1rem)_solid_transparent] before:absolute before:bottom-[-20%] before:left-1/2 before:z-[0] before:h-[20%] before:w-[60%] before:-translate-x-1/2 before:animate-rainbow before:bg-[linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] before:[filter:blur(calc(0.8*1rem))] dark:bg-[linear-gradient(#121213,#121213),linear-gradient(#121213_50%,rgba(18,18,19,0.6)_80%,rgba(18,18,19,0)),linear-gradient(90deg,hsl(0,100%,63%),hsl(90,100%,63%),hsl(210,100%,63%),hsl(195,100%,63%),hsl(270,100%,63%))] hover:scale-105 active:scale-95 h-10 px-4 py-2 inline-flex"
                      >
                        <div className="flex items-center">
                          <span className="text-lg text-purple-700 animate-pulse">
                            <RiGeminiFill />
                          </span>
                          <span className="ml-1 text-black dark:text-white lg:inline p-1">
                            AI Assistant
                          </span>
                        </div>
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            </DialogPanel>
          </Dialog>
        </header>
        <main>
          <Outlet />
        </main>
      </div>
    </>
  );
}

export default App;
