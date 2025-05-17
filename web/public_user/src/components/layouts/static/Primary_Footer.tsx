import {
  IconMailFilled,
  IconBrandInstagram,
  IconBrandStackoverflow,
} from "@tabler/icons-react";
import { FaGithub } from "react-icons/fa6";
import { FaFacebook } from "react-icons/fa6";

export function PrimaryFooterIndexOnly() {
  let getYear = () => {
    let currentYear = new Date().getFullYear();
    return currentYear;
  };

  return (
    <footer className="bottom-0 p-12 pt-6 bg-slate-950 dark:bg-white dark:border-t-4 dark:border-slate-400 backdrop-blur-[25px]">
      <div className="grid max-w-[2000px] grid-cols-1 lg:grid-cols-3 mx-auto w-[80%] justify-items-start mt-6">
        <div className="flex flex-col justify-self-center w-full">
          <img
            alt=""
            src="https://i.postimg.cc/kG6cVZ9f/Name-Admin-Panel-I-Vector-4x.png"
            className="h-auto w-48 invert dark:invert-0 select-none"
          />
        </div>
        <div className="flex flex-col lg:justify-self-center w-full mt-12 lg:mt-0">
          <h5 className="text-[1.4rem] text-white dark:text-black font-bold">
            Contact Us
          </h5>
          <div className="mt-4 flex flex-row w-max h-max">
            <div className="flex justify-center items-center">
              <IconMailFilled className="w-5 h-auto my-auto text-white dark:text-black" />
            </div>
            <div className="my-auto pl-4 text-[0.8rem] text-[#afafaf] dark:text-slate-800">
              <a
                href="mailto:quaristatechuse@gmail.com"
                className="hover:text-white duration-200 dark:hover:text-black"
              >
                contact.quarista@gmail.com
              </a>
            </div>
          </div>
        </div>
        <div className="flex flex-col justify-self-center lg:justify-self-end w-full mt-12 lg:mt-0">
          <h5 className="text-[1.4rem] text-white dark:text-black font-bold">
            Follow Us
          </h5>
          <div className="flex flex-row mt-4 justify-self-center">
            <a
              href="https://github.com/Quarista"
              target="_blank"
              rel="noreferrer"
            >
              <button className="bg-transparent border-none mr-6">
                <FaGithub className="cursor-pointer w-8 h-auto text-white dark:text-black hover:scale-110 duration-200" />
              </button>
            </a>
            <a href="#">
              <button className="bg-transparent border-none mr-6">
                <IconBrandInstagram className="cursor-pointer w-8 h-auto text-white dark:text-black hover:scale-110 duration-200" />
              </button>
            </a>
            <a href="#">
              <button className="bg-transparent border-none mr-6">
                <IconBrandStackoverflow className="cursor-pointer w-8 h-auto text-white dark:text-black hover:scale-110 duration-200" />
              </button>
            </a>
            <a href="#">
              <button
                className="bg-transparent border-none"
                style={{ marginRight: 0 }}
              >
                <FaFacebook className="cursor-pointer w-8 h-auto text-white dark:text-black hover:scale-110 duration-200" />
              </button>
            </a>
          </div>
        </div>
      </div>

      <div className="flex justify-center">
        <hr className="mt-12 mb-8 border-[0.3px] border-[rgba(160,160,160,0.21)] dark:border-[rgba(59,59,59,0.21)] w-[80%] max-w-[2000px]" />
      </div>

      <div
        className="text-center mt-8 mb-8 text-[1rem] text-zinc-200 dark:text-zinc-700"
        id="footerfootertext"
      >
        © {getYear()} | Team Quarista | All Rights Reserved
      </div>
    </footer>
  );
}
