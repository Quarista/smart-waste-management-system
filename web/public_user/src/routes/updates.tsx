import { CopyrightFooter } from "@/components/layouts/static/CC_Footer";
import { Carousel, Card } from "@/components/layouts/updates-carousel";
import { motion } from "framer-motion";
import { useState, useEffect } from "react";
import { db } from "@/backend/firebase";
import { collection, getDocs, query, orderBy } from "firebase/firestore";

export default function UpdateKeynotes() {
  const [cards, setCards] = useState<JSX.Element[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Fetch updates from Firestore
    fetchUpdatesFromFirestore();
  }, []);

  const fetchUpdatesFromFirestore = async () => {
    try {
      setLoading(true);
      const updatesCollection = collection(db, "updatesBlog");
      const q = query(updatesCollection, orderBy("createdAt", "desc"));
      const querySnapshot = await getDocs(q);
      
      const updatesData = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      // Map the data to Card components
      const cardElements = updatesData.map((update: any, index) => (
        <Card 
          key={update.id} 
          card={{
            category: update.category,
            title: update.title,
            src: update.src,
            content: (
              <ContentStructure
                mainImage={update.content.mainImage}
                smallImages={update.content.smallImages}
                overviewText={update.content.overviewText}
                approachText={update.content.approachText}
              />
            )
          }} 
          index={index} 
        />
      ));
      
      setCards(cardElements);
        } catch (error) {
      console.error("Error fetching updates:", error);
      // Show an error message instead of fallback data
      const errorCard = (
        <div className="w-full p-8 rounded-xl bg-red-50 dark:bg-red-900/20 text-center">
          <h3 className="text-xl font-semibold text-red-700 dark:text-red-400 mb-2">Unable to load updates</h3>
          <p className="text-gray-700 dark:text-gray-300">There was a problem retrieving the latest updates. Please try again later.</p>
        </div>
      );
      setCards([errorCard]);
        } finally {
      setLoading(false);
        }
      };


  return (
    <div>
      <motion.div
        initial={{ opacity: 0.0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        transition={{
          delay: 0.3,
          duration: 0.8,
          ease: "easeInOut",
        }}
      >
        <div className="w-full h-full">
                  
          <div className="h-screen w-full pt-24 md:pt-14 flex flex-col md:justify-center my-auto mb-4">
            {loading ? (
              <div className="flex justify-center items-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-zinc-500"></div>
              </div>
            ) : (
              <Carousel items={cards} />
            )}
          </div>
        </div>
      </motion.div>
      <CopyrightFooter />
    </div>
  );
}

interface ContentStructureProps {
  mainImage: string;
  smallImages: string[];
  overviewText: string;
  approachText: string;
}

// Content Structure component remains the same
const ContentStructure = ({
  mainImage,
  smallImages,
  overviewText,
  approachText,
}: ContentStructureProps) => {
  return (
    <>
      <div className="bg-[#F5F5F7] dark:bg-neutral-800/10 p-8 md:p-14 rounded-3xl mb-4">
        <div className="grid grid-cols-3 md:grid-cols-3 gap-4">
          <div className="col-span-3 md:col-span-3">
            <img
              src={mainImage}
              alt="Main"
              className="w-full h-auto rounded-lg blur-sm transition duration-500 ease-in-out"
              onLoad={(e) => e.currentTarget.classList.remove("blur-sm")}
              loading="lazy"
            />
          </div>
          {smallImages.map((src, index) => (
            <img
              key={index}
              src={src}
              alt={`Small ${index + 1}`}
              className="w-full h-auto rounded-lg blur-sm transition duration-500 ease-in-out"
              onLoad={(e) => e.currentTarget.classList.remove("blur-sm")}
              loading="lazy"
            />
          ))}
        </div>
      </div>
      <div className="bg-[#F5F5F7] dark:bg-neutral-800/10 p-8 md:p-14 rounded-3xl mb-4">
        <div className="grid grid-cols-1 md:grid-cols-1 gap-4 text-black dark:text-white">
          <div className="text-left mb-4">
            <h2 className="font-bold text-xl md:text-2xl mb-2">Overview</h2>
            <p className="text-sm md:text-base max-w-prose text-zinc-700 dark:text-zinc-300">
              {overviewText}
            </p>
          </div>
          <div className="text-left mt-4">
            <h2 className="font-bold text-xl md:text-2xl mb-2">Approach</h2>
            <p className="text-sm md:text-base max-w-prose text-zinc-700 dark:text-zinc-300">
              {approachText}
            </p>
          </div>
        </div>
      </div>
    </>
  );
};
