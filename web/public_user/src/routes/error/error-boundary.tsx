import { Component, ErrorInfo, ReactNode } from "react";
import { Button } from "@/components/ui/button";

interface ErrorBoundaryProps {
  children: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    // Update state so the next render will show the fallback UI.
    return {
      hasError: true,
      error,
      errorInfo: null,
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    // You can also log the error to an error reporting service
    console.error("Error caught by ErrorBoundary:", error, errorInfo);
    this.setState({
      error,
      errorInfo,
    });
  }

  render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <div className="flex h-screen flex-col items-center justify-center bg-white dark:bg-black p-6">
          <div className="max-w-md text-center">
            <h1 className="text-4xl font-bold text-red-500 mb-4">
              Something went wrong
            </h1>
            <span className="text-gray-700 dark:text-gray-300 mb-12">
              An unexpected error occurred in server response. Please try again
              later or contact support if the issue persists.
            </span>
            <div className="mb-8 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg text-left overflow-auto max-h-60">
              <span className="font-mono text-sm whitespace-pre-wrap">
                <span className="text-gray-700 dark:text-gray-300">
                  Include this error message when contacting support,
                </span>{" "}
                <br />
                <span className="text-red-500">
                  {this.state.error?.toString()}
                </span>
              </span>
            </div>
            <div className="flex gap-4 justify-center">
              <Button
                onClick={() => window.location.reload()}
                variant="default"
              >
                Reload Page
              </Button>
              <Button
                onClick={() =>
                  (window.location.href = "mailto:contact.quarista@gmail.com")
                }
                variant="outline"
              >
                Contact Support
              </Button>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
