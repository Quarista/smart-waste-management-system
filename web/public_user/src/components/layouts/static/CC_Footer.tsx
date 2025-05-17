import React from 'react';

interface FooterProps {
    year: number;
    companyName: string;
    rightsReserved: string;
}

const FooterText: React.FC<{ text: string }> = ({ text }) => (
    <div className="text-balance text-center text-sm leading-loose text-muted-foreground md:text-left text-gray-800 dark:text-white">
        {text}
    </div>
);

const FooterContainer: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <div className="container-wrapper">
        <div className="container py-3">{children}</div>
    </div>
);

const FooterWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <footer className="border-grid border-t dark:dark:border-zinc-800 py-0 md:px-8 md:py-0 z-40  bottom-0 left-0 right-0 bg-white/40 dark:bg-[#0B0B0F]/40 backdrop-blur-md">
        {children}
    </footer>
);

export function CopyrightFooter() {
    const currentYear = new Date().getFullYear();
    const footerProps: FooterProps = {
        year: currentYear,
        companyName: 'Team Quarista',
        rightsReserved: 'All rights reserved.',
    };

    return (
        <FooterWrapper>
            <FooterContainer>
                <FooterText text={`© ${footerProps.year} ${footerProps.companyName}. ${footerProps.rightsReserved}`} />
            </FooterContainer>
        </FooterWrapper>
    );
}
