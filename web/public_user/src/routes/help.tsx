import { motion } from "framer-motion";
import { CopyrightFooter } from "@/components/layouts/static/CC_Footer";
import { db } from "@/backend/firebase";
import { collection, addDoc } from "firebase/firestore";
import { useState } from "react";
import { toast } from "react-hot-toast";
import { IconUserCircle, IconUserScan, IconArrowRight } from "@tabler/icons-react";
import { cn } from "@/lib/utils";

const forbiddenWords = [
  "<script>",
  "alert(",
  "SELECT * FROM",
  "DROP TABLE",
  "INSERT INTO",
  "DELETE FROM",
  "UPDATE ",
  "ALTER TABLE",
  "CREATE TABLE",
  "EXEC(",
  "UNION SELECT",
  "OR 1=1",
  "--",
  "/*",
  "*/",
  "xp_cmdshell",
  "sp_",
  "0x",
  "char(",
  "nchar(",
  "varchar(",
  "nvarchar(",
  "cast(",
  "convert(",
];

// List of districts for the collector form
const districts = [
  "Colombo",
  "Gampaha",
  "Kalutara",
  "Kandy",
  "Matale",
  "Nuwara Eliya",
  "Galle",
  "Matara",
  "Hambantota",
  "Jaffna",
  "Kilinochchi",
  "Mannar",
  "Vavuniya",
  "Mullaitivu",
  "Batticaloa",
  "Ampara",
  "Trincomalee",
  "Kurunegala",
  "Puttalam",
  "Anuradhapura",
  "Polonnaruwa",
  "Badulla",
  "Monaragala",
  "Ratnapura",
  "Kegalle",
];

export default function HelpDesk() {
  const [selectedForm, setSelectedForm] = useState<string | null>(null);
  
  // Personal form state
  const [personalFormData, setPersonalFormData] = useState({
    firstname: "",
    lastname: "",
    email: "",
    subject: "",
    message: "",
  });
  
  // Collector form state
  const [collectorFormData, setCollectorFormData] = useState({
    firstname: "",
    lastname: "",
    email: "",
    district: "",
    type: "suggestion", // default value
    message: "",
  });
  
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handlePersonalChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setPersonalFormData({
      ...personalFormData,
      [e.target.id]: e.target.value,
    });
  };

  const handleCollectorChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setCollectorFormData({
      ...collectorFormData,
      [e.target.id]: e.target.value,
    });
  };

  const containsForbiddenWords = (text: string) => {
    return forbiddenWords.some((word) => text.includes(word));
  };

  const handlePersonalSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Return early if already submitting
    if (isSubmitting) {
      toast.error("Form is already being submitted, please wait");
      return;
    }

    if (containsForbiddenWords(personalFormData.message)) {
      toast.error(
        "Your submission contains potentially suspicious words, please refine the message"
      );
      return;
    }
    try {
      setIsSubmitting(true);
      const timestamp = new Date().toISOString();
      await addDoc(collection(db, "user_submissions"), {
        ...personalFormData,
        timestamp,
      });
      toast.success("Submission successful!");
      // Clear the form fields
      setPersonalFormData({
        firstname: "",
        lastname: "",
        email: "",
        subject: "",
        message: "",
      });
    } catch (error) {
      console.error("Error adding document: ", error);
      toast.error("Submission failed!");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCollectorSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Return early if already submitting
    if (isSubmitting) {
      toast.error("Form is already being submitted, please wait");
      return;
    }

    if (containsForbiddenWords(collectorFormData.message)) {
      toast.error(
        "Your submission contains potentially suspicious words, please refine the message"
      );
      return;
    }
    try {
      setIsSubmitting(true);
      const timestamp = new Date().toISOString();
      await addDoc(collection(db, "collector_submissions"), {
        ...collectorFormData,
        timestamp,
      });
      toast.success("Submission successful!");
      // Clear the form fields
      setCollectorFormData({
        firstname: "",
        lastname: "",
        email: "",
        district: "",
        type: "suggestion",
        message: "",
      });
    } catch (error) {
      console.error("Error adding document: ", error);
      toast.error("Submission failed!");
    } finally {
      setIsSubmitting(false);
    }
  };


  const renderFormSelector = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-2xl mx-auto">
      <motion.div 
        className={cn(
          "p-6 rounded-xl border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900/50 backdrop-blur shadow-sm hover:shadow-md transition-all duration-200 cursor-pointer flex flex-col items-center justify-center text-center",
          selectedForm === "personal" && "ring-2 ring-blue-500 dark:ring-blue-400"
        )}
        whileHover={{ y: -5 }}
        onClick={() => setSelectedForm("personal")}
      >
        <IconUserCircle className="w-16 h-16 text-blue-500 mb-4" />
        <h3 className="text-xl font-medium text-neutral-800 dark:text-neutral-200 mb-2">Personal Queries</h3>
        <p className="text-sm text-neutral-600 dark:text-neutral-400 mb-4">
          Submit your individual questions, feedback, or support requests
        </p>
        <button 
          className="mt-4 flex items-center gap-2 text-blue-600 dark:text-blue-400 font-medium"
          onClick={() => setSelectedForm("personal")}
        >
          Select <IconArrowRight className="w-4 h-4" />
        </button>
      </motion.div>

      <motion.div 
        className={cn(
          "p-6 rounded-xl border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900/50 backdrop-blur shadow-sm hover:shadow-md transition-all duration-200 cursor-pointer flex flex-col items-center justify-center text-center",
          selectedForm === "collector" && "ring-2 ring-green-500 dark:ring-green-400"
        )}
        whileHover={{ y: -5 }}
        onClick={() => setSelectedForm("collector")}
      >
        <IconUserScan className="w-16 h-16 text-green-500 mb-4" />
        <h3 className="text-xl font-medium text-neutral-800 dark:text-neutral-200 mb-2">For Collectors</h3>
        <p className="text-sm text-neutral-600 dark:text-neutral-400 mb-4">
          Report issues or submit suggestions related to waste collection services
        </p>
        <button 
          className="mt-4 flex items-center gap-2 text-green-600 dark:text-green-400 font-medium"
          onClick={() => setSelectedForm("collector")}
        >
          Select <IconArrowRight className="w-4 h-4" />
        </button>
      </motion.div>
    </div>
  );

  const renderPersonalForm = () => (
    <div className="max-w-lg w-full mx-auto rounded-xl border border-zinc-200 dark:border-zinc-700 p-6 md:p-8 shadow-lg bg-white dark:bg-zinc-900/50 backdrop-blur-sm">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold text-neutral-800 dark:text-neutral-200">Personal Query Form</h2>
        <button 
          onClick={() => setSelectedForm(null)}
          className="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 duration-300"
        >
          Go back
        </button>
      </div>
      
      <form className="space-y-6" onSubmit={handlePersonalSubmit}>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-2">
            <label
              htmlFor="firstname"
              className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
            >
              First name
            </label>
            <input
              id="firstname"
              placeholder="Saman"
              type="text"
              required
              value={personalFormData.firstname}
              onChange={handlePersonalChange}
              className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
            />
          </div>
          <div className="space-y-2">
            <label
              htmlFor="lastname"
              className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
            >
              Last name
            </label>
            <input
              id="lastname"
              placeholder="Perera"
              type="text"
              required
              value={personalFormData.lastname}
              onChange={handlePersonalChange}
              className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
            />
          </div>
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="email"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            Email Address
          </label>
          <input
            id="email"
            placeholder="samanperera@example.com"
            type="email"
            required
            value={personalFormData.email}
            onChange={handlePersonalChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
          />
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="subject"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            Subject
          </label>
          <select
            id="subject"
            required
            value={personalFormData.subject}
            onChange={handlePersonalChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
          >
            <option value="" disabled>Select a subject</option>
            <option value="general">General Inquiry</option>
            <option value="support">Technical Support</option>
            <option value="bug">Bug Report</option>
          </select>
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="message"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            Message
          </label>
          <textarea
            id="message"
            placeholder="Your message here..."
            rows={4}
            required
            value={personalFormData.message}
            onChange={handlePersonalChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
          />
        </div>
        
        <div className="bg-gradient-to-r from-transparent via-neutral-300 dark:via-neutral-700 to-transparent h-[1px] w-full" />
        
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full rounded-md bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 dark:from-blue-500 dark:to-blue-400 dark:hover:from-blue-600 dark:hover:to-blue-500 px-4 py-2.5 text-sm font-medium text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
        >
          {isSubmitting ? (
            <div className="flex items-center justify-center gap-2">
              <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Submitting...
            </div>
          ) : "Submit Request"}
        </button>
      </form>
    </div>
  );

  const renderCollectorForm = () => (
    <div className="max-w-lg w-full mx-auto rounded-xl border border-zinc-200 dark:border-zinc-700 p-6 md:p-8 shadow-lg bg-white dark:bg-zinc-900/50 backdrop-blur-sm">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold text-neutral-800 dark:text-neutral-200">Collector Form</h2>
        <button 
          onClick={() => setSelectedForm(null)}
          className="text-sm text-green-600 dark:text-green-400 hover:text-green-800 dark:hover:text-green-300 duration-300"
        >
          Go back
        </button>
      </div>
      
      <form className="space-y-6" onSubmit={handleCollectorSubmit}>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-2">
            <label
              htmlFor="firstname"
              className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
            >
              First name
            </label>
            <input
              id="firstname"
              placeholder="Saman"
              type="text"
              required
              value={collectorFormData.firstname}
              onChange={handleCollectorChange}
              className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-green-400"
            />
          </div>
          <div className="space-y-2">
            <label
              htmlFor="lastname"
              className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
            >
              Last name
            </label>
            <input
              id="lastname"
              placeholder="Perera"
              type="text"
              required
              value={collectorFormData.lastname}
              onChange={handleCollectorChange}
              className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-green-400"
            />
          </div>
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="email"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            Email Address
          </label>
          <input
            id="email"
            placeholder="samanperera@example.com"
            type="email"
            required
            value={collectorFormData.email}
            onChange={handleCollectorChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-green-400"
          />
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="district"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            District
          </label>
          <select
            id="district"
            required
            value={collectorFormData.district}
            onChange={handleCollectorChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-green-400"
          >
            <option value="" disabled>Select your district</option>
            {districts.map((district) => (
              <option key={district} value={district}>{district}</option>
            ))}
          </select>
        </div>
        
        <div className="space-y-2">
          <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300">
            Type
          </label>
          <div className="grid grid-cols-2 gap-4">
            <label className="flex items-center space-x-3 cursor-pointer">
              <input
                type="radio"
                id="suggestion"
                name="type"
                value="suggestion"
                checked={collectorFormData.type === "suggestion"}
                onChange={handleCollectorChange}
                className="h-4 w-4 text-green-500 focus:ring-green-400 border-gray-300"
              />
              <span className="text-sm text-gray-700 dark:text-gray-300">Suggestion</span>
            </label>
            <label className="flex items-center space-x-3 cursor-pointer">
              <input
                type="radio"
                id="report"
                name="type"
                value="report"
                checked={collectorFormData.type === "report"}
                onChange={handleCollectorChange}
                className="h-4 w-4 text-red-500 focus:ring-red-400 border-gray-300"
              />
              <span className="text-sm text-gray-700 dark:text-gray-300">Report Issue</span>
            </label>
          </div>
        </div>
        
        <div className="space-y-2">
          <label
            htmlFor="message"
            className="text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            Message
          </label>
          <textarea
            id="message"
            placeholder="Your message here..."
            rows={4}
            required
            value={collectorFormData.message}
            onChange={handleCollectorChange}
            className="w-full rounded-md border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-800 px-3 py-2 text-sm text-black dark:text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-green-400"
          />
        </div>
        
        <div className="bg-gradient-to-r from-transparent via-neutral-300 dark:via-neutral-700 to-transparent h-[1px] w-full" />
        
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full rounded-md bg-gradient-to-r from-green-600 to-green-500 hover:from-green-700 hover:to-green-600 dark:from-green-500 dark:to-green-400 dark:hover:from-green-600 dark:hover:to-green-500 px-4 py-2.5 text-sm font-medium text-white shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
        >
          {isSubmitting ? (
            <div className="flex items-center justify-center gap-2">
              <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Submitting...
            </div>
          ) : "Submit Request"}
        </button>
        <div className="mt-1 text-xs text-center text-gray-500 dark:text-gray-400">
          This submission is confidential and will only be reviewed by authorized waste management personnel.
        </div>
      </form>
    </div>
  );

  const renderFormContent = () => {
    if (!selectedForm) return renderFormSelector();
    if (selectedForm === "personal") return renderPersonalForm();
    if (selectedForm === "collector") return renderCollectorForm();
  };

  return (
    <div className="min-h-screen">
      <motion.div
        initial={{ opacity: 0.0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        transition={{
          delay: 0.3,
          duration: 0.8,
          ease: "easeInOut",
        }}
      >
        <div className="w-full min-h-screen flex flex-col lg:flex-row gap-10 justify-center items-center px-4 md:px-6 pt-28 pb-10">
          {/* Left Side - Introduction */}
          <div className="lg:w-1/2 max-w-xl">
            <motion.h1 
              className="text-4xl md:text-6xl font-medium text-center lg:text-left text-neutral-800 dark:text-neutral-200"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5, duration: 0.8 }}
            >
              Help Desk
            </motion.h1>
            <motion.p 
              className="mt-4 text-center lg:text-left text-neutral-700 dark:text-neutral-300"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.7, duration: 0.8 }}
            >
              Get in touch with us for any queries or feedback. We're here to help you with any questions or issues you might have.
            </motion.p>
            
            <motion.div 
              className="mt-8 hidden lg:block"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1, duration: 1 }}
            >
              <div className="p-6 rounded-xl bg-zinc-50 dark:bg-zinc-800/50 backdrop-blur border border-zinc-200 dark:border-zinc-700">
                <h3 className="text-lg font-medium text-neutral-800 dark:text-neutral-200 mb-4">Why Contact Us?</h3>
                <ul className="space-y-2 text-neutral-600 dark:text-neutral-400">
                  <li className="flex items-start">
                    <svg className="h-5 w-5 text-green-500 mr-2 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Get assistance with our services
                  </li>
                  <li className="flex items-start">
                    <svg className="h-5 w-5 text-green-500 mr-2 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Report issues with bin locations or collection
                  </li>
                  <li className="flex items-start">
                    <svg className="h-5 w-5 text-green-500 mr-2 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Provide feedback to help us improve
                  </li>
                  <li className="flex items-start">
                    <svg className="h-5 w-5 text-green-500 mr-2 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Request information about our services
                  </li>
                </ul>
              </div>
            </motion.div>
          </div>

          <div className="lg:w-1/2 w-full">
            {renderFormContent()}
          </div>
        </div>
      </motion.div>
      <CopyrightFooter />
    </div>
  );
}
