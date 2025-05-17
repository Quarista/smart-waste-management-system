import { Info } from "lucide-react";
import { motion } from "framer-motion";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { cn } from "@/lib/utils";
import {
  IconCloud,
  IconClockCheck,
  IconMessageChatbot,
  IconMessage2Exclamation,
} from "@tabler/icons-react";
import { CopyrightFooter } from "@/components/layouts/static/CC_Footer";

export default function ServiceExplorer() {
  const features = [
    {
      title: "Weather Information",
      description:
        "A detailed weather data in the area where dustbin is placed even the upcoming weather conditions.",
      icon: <IconCloud />,
    },
    {
      title: "Real-time data update",
      description:
        "Send information about the garbage level in real-time and display it to user.",
      icon: <IconClockCheck />,
    },
    {
      title: "Multi-Functional Chatbot  ",
      description:
        "An Multi-Functional AI Assistant that can help you with your queries related to our services.",
      icon: <IconMessageChatbot />,
    },
    {
      title: "Fallout reminder",
      description:
        "The system detects if a dustbin has fallen over and alerts the user about it.",
      icon: <IconMessage2Exclamation />,
    },
  ];

  return (
    <div>
      <div className="h-full md:h-screen w-full flex flex-col justify-center items-center py-16">
        <motion.div
          initial={{ opacity: 0.0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{
            delay: 0.3,
            duration: 0.8,
            ease: "easeInOut",
          }}
        >
          <div>
            <div className="pt-16">
              <h4 className="text-3xl lg:text-5xl lg:leading-tight max-w-5xl mx-auto text-center tracking-tight font-medium text-black dark:text-white">
                Services
              </h4>

              <p className="text-sm lg:text-base  max-w-2xl  my-4 mx-auto text-neutral-500 text-center font-normal dark:text-neutral-300">
                What you can expect from our website?
              </p>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4  relative z-10 py-10 max-w-7xl mx-auto">
            {features.map((feature, index) => (
              <Feature key={feature.title} {...feature} index={index} />
            ))}
          </div>
          <div className="max-w-xl mx-auto">
            <Alert variant="destructive">
              <Info className="h-5 w-5" />
              <AlertTitle>Any Suggestions?</AlertTitle>
              <AlertDescription>
                If you have any suggestions for us, feel free to contact us via{" "}
                <a
                  href="mailto:contact.quarista@gmail.com"
                  className="underline"
                >
                  email
                </a>
                .
              </AlertDescription>
            </Alert>
          </div>
        </motion.div>
      </div>
      <CopyrightFooter />
    </div>
  );
}

const Feature = ({
  title,
  description,
  icon,
  index,
}: {
  title: string;
  description: string;
  icon: React.ReactNode;
  index: number;
}) => {
  return (
    <div
      className={cn(
        "flex flex-col lg:border-r  py-10 relative group/feature dark:border-neutral-800",
        (index === 0 || index === 4) && "lg:border-l dark:border-neutral-800",
        index < 4 && "lg:border-b dark:border-neutral-800"
      )}
    >
      {index < 4 && (
        <div className="opacity-0 group-hover/feature:opacity-100 transition duration-200 absolute inset-0 h-full w-full bg-gradient-to-t from-neutral-100 dark:from-neutral-800 to-transparent pointer-events-none" />
      )}
      {index >= 4 && (
        <div className="opacity-0 group-hover/feature:opacity-100 transition duration-200 absolute inset-0 h-full w-full bg-gradient-to-b from-neutral-100 dark:from-neutral-800 to-transparent pointer-events-none" />
      )}
      <div className="mb-4 relative z-10 px-10 text-neutral-600 dark:text-neutral-400">
        {icon}
      </div>
      <div className="text-lg font-bold mb-2 relative z-10 px-10">
        <div className="absolute left-0 inset-y-0 h-6 group-hover/feature:h-8 w-1 rounded-tr-full rounded-br-full bg-neutral-300 dark:bg-neutral-700 group-hover/feature:bg-blue-500 transition-all duration-200 origin-center" />
        <span className="group-hover/feature:translate-x-2 transition duration-200 inline-block text-neutral-800 dark:text-neutral-100">
          {title}
        </span>
      </div>
      <p className="text-sm text-neutral-600 dark:text-neutral-300 max-w-xs relative z-10 px-10">
        {description}
      </p>
    </div>
  );
};
