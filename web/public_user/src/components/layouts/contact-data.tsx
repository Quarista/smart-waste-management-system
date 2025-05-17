import { cn } from "../../lib/utils";
import {
  EnvelopeIcon,
  ChatBubbleLeftIcon,
  PhoneIcon,
} from "@heroicons/react/24/solid";
import { Toaster, toast } from "react-hot-toast";

export function ContactData() {
  const features = [
    {
      title: "Email",
      description: "contact.quarista@gmail.com",
      icon: <EnvelopeIcon />,
    },
    {
      title: "Business Contact",
      description: "0771568149",
      icon: <ChatBubbleLeftIcon />,
    },
    {
      title: "Contact",
      description: "0771568149",
      icon: <PhoneIcon />,
    },
  ];
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-3  relative z-10 py-10 max-w-7xl mx-auto">
      {features.map((feature, index) => (
        <Feature key={feature.title} {...feature} index={index} />
      ))}
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
    <div>
      <Toaster />
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
        <div className="mb-8 relative z-10 h-4 ml-8 w-6 text-neutral-600 dark:text-neutral-400">
          {icon}
        </div>
        <div className="text-lg font-bold mb-2 relative z-10 px-10">
          <div className="absolute left-0 inset-y-0 h-6 group-hover/feature:h-8 w-1 rounded-tr-full rounded-br-full bg-neutral-300 dark:bg-neutral-700 group-hover/feature:bg-blue-500 transition-all duration-200 origin-center" />
          <span className="group-hover/feature:translate-x-2 transition duration-200 inline-block text-neutral-800 dark:text-neutral-100">
            {title}
          </span>
        </div>
        {title === "Email" ? (
          <a
            href={`mailto:${description}`}
            className="text-sm text-neutral-600 dark:text-neutral-300 max-w-xs relative z-10 px-10 cursor-pointer"
          >
            {description}
          </a>
        ) : title === "Contact" ? (
          <a
            href={`tel:${description}`}
            className="text-sm text-neutral-600 dark:text-neutral-300 max-w-xs relative z-10 px-10 cursor-pointer"
          >
            {description}
          </a>
        ) : title === "Business Contact" ? (
          <a
            href={`https://wa.me/${description}`}
            className="text-sm text-neutral-600 dark:text-neutral-300 max-w-xs relative z-10 px-10 cursor-pointer"
            target="_blank"
            rel="noopener noreferrer"
          >
            {description}
          </a>
        ) : (
          <span
            className="text-sm text-neutral-600 dark:text-neutral-300 max-w-xs relative z-10 px-10 cursor-pointer"
            onClick={() => {
              navigator.clipboard.writeText(description);
              toast.success("Copied to clipboard!");
            }}
          >
            {description}
          </span>
        )}
      </div>
    </div>
  );
};
