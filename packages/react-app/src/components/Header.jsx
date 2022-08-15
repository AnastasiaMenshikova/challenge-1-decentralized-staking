import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/scaffold-eth/scaffold-eth" /*target="_blank" rel="noopener noreferrer"*/>
      <PageHeader
        title="🏗 scaffold-eth"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
